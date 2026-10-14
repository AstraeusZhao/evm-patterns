use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    routing::get,
    Json, Router,
};
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    env, fs, io,
    net::SocketAddr,
    path::{Path as FsPath, PathBuf},
    process::Command,
};
use tokio::net::TcpListener;

#[derive(Clone)]
struct AppState {
    root: PathBuf,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct Catalog {
    git: GitStatus,
    coverage_baseline: CoverageBaseline,
    contracts: Vec<Contract>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct GitStatus {
    branch: Option<String>,
    revision: Option<String>,
    dirty: bool,
    changed_files: usize,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct CoverageBaseline {
    revision: String,
    date: String,
    tests: usize,
    line_percent: f64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct Contract {
    id: String,
    name: String,
    family: String,
    path: String,
    summary: String,
    compiler: String,
    group: String,
    tags: Vec<String>,
    line_coverage: Option<f64>,
    dedicated_tests: Vec<String>,
    design_path: Option<String>,
}

#[derive(Serialize)]
struct Content {
    content: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = find_repo_root()?;
    let address: SocketAddr = env::var("EVM_PATTERNS_API_ADDR")
        .unwrap_or_else(|_| "127.0.0.1:3001".to_owned())
        .parse()?;
    let state = AppState { root };
    let app = Router::new()
        .route("/api/health", get(health))
        .route("/api/catalog", get(catalog))
        .route("/api/contracts/{id}/source", get(contract_source))
        .route("/api/contracts/{id}/design", get(contract_design))
        .route("/api/contracts/{id}/file", get(contract_file))
        .with_state(state);
    let listener = TcpListener::bind(address).await?;
    println!("EVM Patterns API listening on http://{address}");
    axum::serve(listener, app).await?;
    Ok(())
}

async fn health() -> &'static str {
    "ok"
}

async fn catalog(State(state): State<AppState>) -> Result<Json<Catalog>, ApiError> {
    build_catalog(&state.root)
        .map(Json)
        .map_err(|_| internal_error())
}

async fn contract_source(
    Path(id): Path<String>,
    State(state): State<AppState>,
) -> Result<Json<Content>, ApiError> {
    let catalog = build_catalog(&state.root).map_err(|_| internal_error())?;
    let contract = catalog
        .contracts
        .iter()
        .find(|contract| contract.id == id)
        .ok_or_else(not_found)?;
    let content =
        fs::read_to_string(state.root.join(&contract.path)).map_err(|_| internal_error())?;
    Ok(Json(Content { content }))
}

async fn contract_design(
    Path(id): Path<String>,
    State(state): State<AppState>,
) -> Result<Json<Content>, ApiError> {
    let catalog = build_catalog(&state.root).map_err(|_| internal_error())?;
    let contract = catalog
        .contracts
        .iter()
        .find(|contract| contract.id == id)
        .ok_or_else(not_found)?;
    let design_path = contract.design_path.as_ref().ok_or_else(not_found)?;
    let content = fs::read_to_string(state.root.join(design_path)).map_err(|_| internal_error())?;
    Ok(Json(Content { content }))
}

type ApiError = (StatusCode, &'static str);

#[derive(Deserialize)]
struct FileQuery {
    path: String,
}

async fn contract_file(
    Path(id): Path<String>,
    Query(query): Query<FileQuery>,
    State(state): State<AppState>,
) -> Result<Json<Content>, ApiError> {
    let catalog = build_catalog(&state.root).map_err(|_| internal_error())?;
    let contract = catalog
        .contracts
        .iter()
        .find(|contract| contract.id == id)
        .ok_or_else(not_found)?;
    if query.path != contract.path && !contract.dedicated_tests.contains(&query.path) {
        return Err(not_found());
    }
    let content = fs::read_to_string(state.root.join(query.path)).map_err(|_| internal_error())?;
    Ok(Json(Content { content }))
}

fn internal_error() -> ApiError {
    (StatusCode::INTERNAL_SERVER_ERROR, "repository scan failed")
}

fn not_found() -> ApiError {
    (StatusCode::NOT_FOUND, "contract not found")
}

fn find_repo_root() -> io::Result<PathBuf> {
    if let Some(root) = env::var_os("EVM_PATTERNS_ROOT") {
        return Ok(PathBuf::from(root));
    }

    env::current_dir()?
        .ancestors()
        .find(|path| path.join("foundry.toml").is_file() && path.join("src").is_dir())
        .map(PathBuf::from)
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "repository root not found"))
}

fn build_catalog(root: &FsPath) -> io::Result<Catalog> {
    let mut sources = Vec::new();
    let mut designs = Vec::new();
    let mut tests = Vec::new();
    collect_files(&root.join("src"), ".sol", &mut sources)?;
    collect_files(&root.join("docs/design"), ".md", &mut designs)?;
    collect_files(&root.join("test"), ".t.sol", &mut tests)?;
    collect_files(&root.join("test"), ".ts", &mut tests)?;
    collect_files(&root.join("tests"), ".ts", &mut tests)?;
    sources.sort();
    designs.sort();
    tests.sort();

    let design_by_family: HashMap<String, PathBuf> = designs
        .into_iter()
        .filter_map(|path| {
            let stem = path.file_stem()?.to_string_lossy().into_owned();
            Some((normalize(&stem), path))
        })
        .collect();
    let coverage_report =
        fs::read_to_string(root.join("docs/reports/AUDIT_COVERAGE.md")).unwrap_or_default();
    let coverage = parse_coverage(&coverage_report);
    let mut contracts = Vec::with_capacity(sources.len());

    for source_path in sources {
        let source = fs::read_to_string(&source_path)?;
        let family = source_path
            .parent()
            .and_then(FsPath::file_name)
            .or_else(|| source_path.file_stem())
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        let id = family.clone();
        let source_text = source.to_ascii_lowercase();
        let group = contract_group(&family, &source_text);
        let source_relative = relative_path(root, &source_path);
        let test_prefix = format!("test/{family}/");
        let tests_prefix = format!("tests/{family}/");
        let dedicated_tests = tests
            .iter()
            .map(|path| relative_path(root, path))
            .filter(|path| path.starts_with(&test_prefix) || path.starts_with(&tests_prefix))
            .collect();
        let design_path = design_by_family
            .get(&normalize(&family))
            .map(|path| relative_path(root, path));
        let summary = extract_notice(&source)
            .filter(|notice| !notice.is_empty())
            .unwrap_or_else(|| format!("{family} Solidity contract example"));

        contracts.push(Contract {
            id,
            name: source_path
                .file_name()
                .unwrap_or_default()
                .to_string_lossy()
                .into_owned(),
            family: family.clone(),
            path: source_relative,
            summary,
            compiler: solidity_pragma(&source),
            group: group.to_owned(),
            tags: contract_tags(&family, &source_text, group),
            line_coverage: coverage.get(&family).copied(),
            dedicated_tests,
            design_path,
        });
    }

    contracts.sort_by(|left, right| left.family.cmp(&right.family));
    Ok(Catalog {
        git: git_status(root),
        coverage_baseline: parse_baseline(&coverage_report),
        contracts,
    })
}

fn collect_files(directory: &FsPath, suffix: &str, files: &mut Vec<PathBuf>) -> io::Result<()> {
    if !directory.exists() {
        return Ok(());
    }

    for entry in fs::read_dir(directory)? {
        let entry = entry?;
        let path = entry.path();
        if entry.file_type()?.is_dir() {
            collect_files(&path, suffix, files)?;
        } else if path
            .file_name()
            .and_then(|name| name.to_str())
            .is_some_and(|name| name.ends_with(suffix))
        {
            files.push(path);
        }
    }
    Ok(())
}

fn relative_path(root: &FsPath, path: &FsPath) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}

fn normalize(value: &str) -> String {
    value
        .chars()
        .filter(|character| character.is_ascii_alphanumeric())
        .flat_map(char::to_lowercase)
        .collect()
}

fn contract_group(family: &str, source: &str) -> &'static str {
    let name = normalize(family);
    if [
        "blocktimestamp",
        "randomness",
        "txoriginauth",
        "uncheckedcall",
        "reentrancyguard",
        "signaturereplay",
        "storagecollision",
        "selfdestruct",
        "frontrunning",
        "eip712",
    ]
    .iter()
    .any(|word| name.contains(word))
    {
        "security"
    } else if [
        "ownable",
        "pausable",
        "timelock",
        "multisig",
        "governance",
        "whitelist",
    ]
    .iter()
    .any(|word| name.contains(word))
    {
        "governance"
    } else if [
        "erc20",
        "erc721",
        "erc1155",
        "batchmint",
        "vesting",
        "royalty",
        "merkleairdrop",
        "safeerc20",
    ]
    .iter()
    .any(|word| name.contains(word))
    {
        "token"
    } else if [
        "amm",
        "bondingcurve",
        "auction",
        "flashloan",
        "staking",
        "marketplace",
        "priceoracle",
    ]
    .iter()
    .any(|word| name.contains(word))
    {
        "defi"
    } else if source.contains("tx.origin") || source.contains("selfdestruct") {
        "security"
    } else {
        "core"
    }
}

fn contract_tags(family: &str, source: &str, group: &str) -> Vec<String> {
    let labels = [
        ("erc20", "ERC-20"),
        ("erc-20", "ERC-20"),
        ("erc721", "ERC-721"),
        ("erc-721", "ERC-721"),
        ("erc1155", "ERC-1155"),
        ("erc-1155", "ERC-1155"),
        ("eip712", "签名"),
        ("proxy", "代理"),
        ("reentrancy", "重入"),
        ("merkle", "Merkle"),
        ("auction", "拍卖"),
    ];
    let searchable = format!("{} {family}", source.to_ascii_lowercase());
    let mut tags = vec![group_label(group).to_owned()];
    for (needle, label) in labels {
        if searchable.contains(needle) && !tags.iter().any(|tag| tag == label) && tags.len() < 4 {
            tags.push(label.to_owned());
        }
    }
    tags
}

fn group_label(group: &str) -> &'static str {
    match group {
        "token" => "代币与 NFT",
        "defi" => "DeFi 与市场",
        "governance" => "治理与权限",
        "security" => "安全示例",
        _ => "基础模式",
    }
}

fn extract_notice(source: &str) -> Option<String> {
    let lines: Vec<&str> = source.lines().collect();
    let start = lines.iter().position(|line| line.contains("@notice"))?;
    let mut parts = Vec::new();

    for line in lines.iter().skip(start) {
        let Some(content) = line.trim().strip_prefix("///").map(str::trim) else {
            break;
        };
        if let Some(notice) = content.strip_prefix("@notice") {
            parts.push(notice.trim());
        } else if content.starts_with('@') {
            break;
        } else if !content.is_empty() {
            parts.push(content);
        }
    }
    Some(parts.join(" "))
}

fn solidity_pragma(source: &str) -> String {
    source
        .lines()
        .find(|line| line.trim_start().starts_with("pragma solidity"))
        .and_then(|line| line.split_once("solidity"))
        .map(|(_, version)| version.trim().trim_end_matches(';').trim().to_owned())
        .filter(|version| !version.is_empty())
        .unwrap_or_else(|| "unknown".to_owned())
}

fn parse_coverage(report: &str) -> HashMap<String, f64> {
    let mut coverage = HashMap::new();
    for line in report.lines() {
        let cells: Vec<&str> = line
            .split('|')
            .map(str::trim)
            .filter(|cell| !cell.is_empty())
            .collect();
        if cells.len() < 2 || !cells[0].starts_with("src/") {
            continue;
        }
        let Some(family) = cells[0].split('/').nth(1) else {
            continue;
        };
        if let Some(percent) = cells[1]
            .split('%')
            .next()
            .and_then(|value| value.trim().parse().ok())
        {
            coverage.insert(family.to_owned(), percent);
        }
    }
    coverage
}

fn parse_baseline(report: &str) -> CoverageBaseline {
    let baseline = report
        .lines()
        .find(|line| line.starts_with("Source baseline:"));
    let revision = baseline
        .and_then(|line| line.split('`').nth(1))
        .unwrap_or("unknown")
        .to_owned();
    let date = baseline
        .and_then(|line| line.split_once('('))
        .and_then(|(_, rest)| rest.split_once(')'))
        .map(|(date, _)| date.to_owned())
        .unwrap_or_else(|| "unknown".to_owned());
    let tests = report
        .split("passed ")
        .nth(1)
        .and_then(|rest| rest.split_whitespace().next())
        .and_then(|value| value.parse().ok())
        .unwrap_or(0);
    let line_percent = report
        .lines()
        .find(|line| line.starts_with("| Total"))
        .and_then(|line| line.split('|').nth(2))
        .and_then(|cell| cell.split('%').next())
        .and_then(|value| value.trim().parse().ok())
        .unwrap_or(0.0);

    CoverageBaseline {
        revision,
        date,
        tests,
        line_percent,
    }
}

fn git_status(root: &FsPath) -> GitStatus {
    let status = git_output(root, &["status", "--porcelain"]).unwrap_or_default();
    let changed_files = status.lines().filter(|line| !line.is_empty()).count();
    GitStatus {
        branch: git_output(root, &["branch", "--show-current"]).filter(|value| !value.is_empty()),
        revision: git_output(root, &["rev-parse", "--short", "HEAD"]),
        dirty: changed_files > 0,
        changed_files,
    }
}

fn git_output(root: &FsPath, arguments: &[&str]) -> Option<String> {
    let output = Command::new("git")
        .arg("-C")
        .arg(root)
        .args(arguments)
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    Some(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

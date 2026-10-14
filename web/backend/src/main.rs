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

#[derive(Clone, Copy, Default, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
enum Framework {
    #[default]
    Foundry,
    Hardhat,
    Truffle,
    Ape,
}

impl Framework {
    fn supports_test(self, path: &FsPath) -> bool {
        match path.extension().and_then(|value| value.to_str()) {
            Some("sol") => matches!(self, Self::Foundry),
            Some("ts" | "js") => matches!(self, Self::Hardhat | Self::Truffle),
            Some("py") => matches!(self, Self::Ape),
            _ => false,
        }
    }
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct ProjectNode {
    name: String,
    path: String,
    kind: &'static str,
    children: Vec<ProjectNode>,
}

#[derive(Default, Deserialize)]
struct TreeQuery {
    #[serde(default)]
    framework: Framework,
}

#[derive(Default, Deserialize)]
struct LocaleQuery {
    #[serde(default)]
    locale: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = find_repo_root()?;
    initialise_project_directories(&root)?;
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
        .route("/api/contracts/{id}/files", get(project_files))
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
    Query(query): Query<LocaleQuery>,
    State(state): State<AppState>,
) -> Result<Json<Content>, ApiError> {
    let catalog = build_catalog(&state.root).map_err(|_| internal_error())?;
    let contract = catalog
        .contracts
        .iter()
        .find(|contract| contract.id == id)
        .ok_or_else(not_found)?;
    let design_path = contract.design_path.as_ref().ok_or_else(not_found)?;
    let locale = match query.locale.as_str() {
        "zh-CN" | "zh-TW" | "de" | "nl" => query.locale.as_str(),
        _ => "en-GB",
    };
    let path = if locale == "en-GB" {
        state.root.join(design_path)
    } else {
        state
            .root
            .join("docs")
            .join("i18n")
            .join(locale)
            .join("design")
            .join(FsPath::new(design_path).file_name().ok_or_else(not_found)?)
    };
    let content = fs::read_to_string(&path)
        .or_else(|_| fs::read_to_string(state.root.join(design_path)))
        .map_err(|_| internal_error())?;
    Ok(Json(Content { content }))
}

type ApiError = (StatusCode, &'static str);

#[derive(Deserialize)]
struct FileQuery {
    path: String,
    #[serde(default)]
    framework: Framework,
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
    let tree = project_tree(&state.root, &contract.family, query.framework)
        .map_err(|_| internal_error())?;
    if !tree_contains(&tree, &query.path) {
        return Err(not_found());
    }
    let content = fs::read_to_string(state.root.join(query.path)).map_err(|_| internal_error())?;
    Ok(Json(Content { content }))
}

async fn project_files(
    Path(id): Path<String>,
    Query(query): Query<TreeQuery>,
    State(state): State<AppState>,
) -> Result<Json<Vec<ProjectNode>>, ApiError> {
    let catalog = build_catalog(&state.root).map_err(|_| internal_error())?;
    let contract = catalog
        .contracts
        .iter()
        .find(|contract| contract.id == id)
        .ok_or_else(not_found)?;
    project_tree(&state.root, &contract.family, query.framework)
        .map(Json)
        .map_err(|_| internal_error())
}

fn tree_contains(nodes: &[ProjectNode], path: &str) -> bool {
    nodes.iter().any(|node| {
        (node.kind == "file" && node.path == path) || tree_contains(&node.children, path)
    })
}

fn hidden_entry(name: &str) -> bool {
    name.starts_with('.') || matches!(name, "lib" | "out" | "cache" | "broadcast")
}

fn project_tree(root: &FsPath, family: &str, framework: Framework) -> io::Result<Vec<ProjectNode>> {
    ["src", "test", "script"]
        .into_iter()
        .map(|name| {
            let directory = root.join(name).join(family);
            let children = read_project_directory(root, &directory, name == "test", framework)?;
            Ok(ProjectNode {
                name: name.to_owned(),
                path: relative_path(root, &directory),
                kind: "directory",
                children,
            })
        })
        .collect()
}

fn read_project_directory(
    root: &FsPath,
    directory: &FsPath,
    tests: bool,
    framework: Framework,
) -> io::Result<Vec<ProjectNode>> {
    if !directory.is_dir() {
        return Ok(Vec::new());
    }
    let mut nodes = Vec::new();
    for entry in fs::read_dir(directory)? {
        let entry = entry?;
        let name = entry.file_name().to_string_lossy().into_owned();
        let kind = entry.file_type()?;
        if hidden_entry(&name) || kind.is_symlink() {
            continue;
        }
        let path = entry.path();
        if kind.is_dir() {
            nodes.push(ProjectNode {
                name,
                path: relative_path(root, &path),
                kind: "directory",
                children: read_project_directory(root, &path, tests, framework)?,
            });
        } else if kind.is_file() && (!tests || framework.supports_test(&path)) {
            nodes.push(ProjectNode {
                name,
                path: relative_path(root, &path),
                kind: "file",
                children: Vec::new(),
            });
        }
    }
    nodes.sort_by(|a, b| {
        (a.kind != "directory", a.name.to_lowercase())
            .cmp(&(b.kind != "directory", b.name.to_lowercase()))
    });
    Ok(nodes)
}

fn initialise_project_directories(root: &FsPath) -> io::Result<()> {
    for entry in fs::read_dir(root.join("src"))? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() || hidden_entry(&entry.file_name().to_string_lossy()) {
            continue;
        }
        for name in ["src", "test", "script"] {
            let directory = root.join(name).join(entry.file_name());
            fs::create_dir_all(&directory)?;
            preserve_empty_directories(&directory)?;
        }
    }
    Ok(())
}

fn preserve_empty_directories(directory: &FsPath) -> io::Result<()> {
    let entries = fs::read_dir(directory)?.collect::<Result<Vec<_>, _>>()?;
    if entries.is_empty() {
        fs::write(directory.join(".gitkeep"), "")?;
    }
    for entry in entries {
        if entry.file_type()?.is_dir() && !hidden_entry(&entry.file_name().to_string_lossy()) {
            preserve_empty_directories(&entry.path())?;
        }
    }
    Ok(())
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

    let mut projects: HashMap<String, Vec<PathBuf>> = HashMap::new();
    for path in sources {
        if let Some(family) = path
            .strip_prefix(root.join("src"))
            .ok()
            .and_then(|path| path.components().next())
        {
            projects
                .entry(family.as_os_str().to_string_lossy().into_owned())
                .or_default()
                .push(path);
        }
    }
    for (family, mut paths) in projects {
        paths.sort_by_key(|path| {
            (
                path.file_stem().and_then(|name| name.to_str()) != Some(family.as_str()),
                path.clone(),
            )
        });
        let source_path = &paths[0];
        let source = fs::read_to_string(source_path)?;
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
        if hidden_entry(&entry.file_name().to_string_lossy()) || entry.file_type()?.is_symlink() {
            continue;
        }
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

fn contract_group(family: &str, _source: &str) -> &'static str {
    match family {
        "ERC20Token" | "ERC20Permit" | "SafeERC20Wrapper" => "token",
        "ERC721NFT" | "ERC1155" | "BatchMint" | "Royalty" | "NFTMarketplace" => "nft",
        "AMM" | "BondingCurve" | "PriceOracle" => "defi",
        "StakingVault" => "staking",
        "DutchAuction" | "EnglishAuction" => "auctionGroup",
        "VestingWallet" | "TokenVesting" | "MerkleAirdrop" => "distribution",
        "EscrowVault" | "PullPayment" | "PullPaymentVault" | "Crowdfunding" => "payments",
        "Ownable" | "Pausable" | "Whitelist" => "access",
        "GovernanceToken" | "MultiSigWallet" | "TimelockController" => "governance",
        "UUPSProxy" | "FactoryClone" => "architecture",
        "SignatureReplay" | "EIP712" => "cryptography",
        "FlashLoanReceiver" => "flashloans",
        "BlockTimestamp" | "Randomness" | "TxOriginAuth" | "UncheckedCall" | "ReentrancyGuard"
        | "StorageCollision" | "SelfDestructDemo" | "FrontRunning" => "security",
        _ => "core",
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
        "nft" => "NFT",
        "defi" => "DeFi 与市场",
        "staking" => "质押",
        "auctionGroup" => "拍卖",
        "distribution" => "分发",
        "payments" => "支付与托管",
        "access" => "权限控制",
        "governance" => "治理与权限",
        "architecture" => "架构与工厂",
        "cryptography" => "密码学",
        "flashloans" => "闪电贷",
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::{SystemTime, UNIX_EPOCH};

    struct Fixture(PathBuf);

    impl Fixture {
        fn new() -> Self {
            let suffix = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos();
            let root = env::temp_dir().join(format!("evm-patterns-tree-{suffix}"));
            fs::create_dir_all(&root).unwrap();
            Self(root)
        }

        fn write(&self, path: &str, content: &str) {
            let path = self.0.join(path);
            fs::create_dir_all(path.parent().unwrap()).unwrap();
            fs::write(path, content).unwrap();
        }
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            let root = self.0.canonicalize().unwrap();
            let temporary = env::temp_dir().canonicalize().unwrap();
            assert!(root.starts_with(&temporary) && root != temporary);
            assert!(root
                .file_name()
                .unwrap()
                .to_string_lossy()
                .starts_with("evm-patterns-tree-"));
            fs::remove_dir_all(root).unwrap();
        }
    }

    #[test]
    fn framework_filters_test_extensions() {
        assert!(Framework::Foundry.supports_test(FsPath::new("Counter.t.sol")));
        assert!(!Framework::Foundry.supports_test(FsPath::new("Counter.ts")));
        assert!(Framework::Hardhat.supports_test(FsPath::new("Counter.ts")));
        assert!(Framework::Truffle.supports_test(FsPath::new("counter.test.js")));
        assert!(Framework::Ape.supports_test(FsPath::new("test_counter.py")));
        assert!(!Framework::Ape.supports_test(FsPath::new("README.md")));
    }

    #[test]
    fn tree_keeps_empty_directories_and_hides_generated_files() {
        let fixture = Fixture::new();
        let root = &fixture.0;
        fs::create_dir_all(root.join("src/Example/nested/empty")).expect("src");
        fs::create_dir_all(root.join("test/Example")).expect("test");
        fs::create_dir_all(root.join("script/Example/lib")).expect("script");
        fs::write(root.join("src/Example/Main.sol"), "contract Main {}").expect("source");
        fs::write(root.join("src/Example/.gitkeep"), "").expect("placeholder");
        fs::write(root.join("test/Example/Counter.t.sol"), "").expect("foundry test");
        fs::write(root.join("test/Example/Counter.ts"), "").expect("hardhat test");
        fs::write(root.join("script/Example/Deploy.s.sol"), "").expect("script");
        fs::write(root.join("script/Example/lib/Hidden.sol"), "").expect("generated");

        let foundry = project_tree(&root, "Example", Framework::Foundry).expect("tree");
        assert!(tree_contains(&foundry, "src/Example/Main.sol"));
        assert_eq!(foundry[0].children[0].name, "nested");
        assert_eq!(foundry[0].children[0].children[0].name, "empty");
        assert!(foundry[0].children[0].children[0].children.is_empty());
        assert!(tree_contains(&foundry, "test/Example/Counter.t.sol"));
        assert!(!tree_contains(&foundry, "test/Example/Counter.ts"));
        assert!(!tree_contains(&foundry, "src/Example/.gitkeep"));
        assert!(!tree_contains(&foundry, "script/Example/lib/Hidden.sol"));

        let hardhat = project_tree(&root, "Example", Framework::Hardhat).expect("tree");
        assert!(tree_contains(&hardhat, "test/Example/Counter.ts"));
        assert!(!tree_contains(&hardhat, "test/Example/Counter.t.sol"));

        assert!(!tree_contains(&foundry, "src/Other/Main.sol"));
        assert!(!tree_contains(&foundry, "src/Example/../../Other/Main.sol"));
    }

    #[test]
    fn skeleton_preserves_empty_nested_folders_without_creating_test_files() {
        let fixture = Fixture::new();
        fixture.write("src/Example/Example.sol", "contract Example {}");
        fs::create_dir_all(fixture.0.join("src/Example/helpers/empty")).unwrap();
        initialise_project_directories(&fixture.0).unwrap();
        for path in [
            "src/Example/helpers/empty/.gitkeep",
            "test/Example/.gitkeep",
            "script/Example/.gitkeep",
        ] {
            assert!(fixture.0.join(path).is_file());
        }
        let tree = project_tree(&fixture.0, "Example", Framework::Foundry).unwrap();
        assert!(tree[1].children.is_empty() && tree[2].children.is_empty());
    }

    #[tokio::test]
    async fn nested_helpers_do_not_create_projects_and_file_access_is_scoped() {
        let fixture = Fixture::new();
        fixture.write("src/Example/Example.sol", "contract Example {}");
        fixture.write("src/Example/helpers/Helper.sol", "contract Helper {}");
        fixture.write("src/Other/Other.sol", "contract Other {}");
        fixture.write("test/Example/test_example.py", "pass");
        let catalog = build_catalog(&fixture.0).unwrap();
        assert_eq!(catalog.contracts.len(), 2);
        assert_eq!(catalog.contracts[0].path, "src/Example/Example.sol");
        for path in [
            "src/Other/Other.sol",
            "src/Example/../../Other/Other.sol",
            "test/Example/test_example.py",
        ] {
            let result = contract_file(
                Path("Example".into()),
                Query(FileQuery {
                    path: path.into(),
                    framework: Framework::Foundry,
                }),
                State(AppState {
                    root: fixture.0.clone(),
                }),
            )
            .await;
            assert_eq!(result.err().unwrap().0, StatusCode::NOT_FOUND);
        }
        let result = contract_file(
            Path("Example".into()),
            Query(FileQuery {
                path: "test/Example/test_example.py".into(),
                framework: Framework::Ape,
            }),
            State(AppState {
                root: fixture.0.clone(),
            }),
        )
        .await
        .unwrap();
        assert_eq!(result.0.content, "pass");
    }
}

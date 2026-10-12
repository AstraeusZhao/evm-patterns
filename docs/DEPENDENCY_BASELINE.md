# Dependency baseline

Use committed lockfiles and pinned CI toolchains. Node 24.20.0/npm 11.19.0 apply to npm applications; Modelnex uses pnpm 11.15.1 with frozen lockfile. Official npm registry is explicit. Go services use 1.26.5 and tidy module graphs. Rust uses 1.97.1 and Cargo.lock. The frontend dependency audits returned zero known advisories for the reviewed lockfiles at this audit snapshot; database updates may change results. Native/Go/Solidity dependencies and application correctness have separate scope; absence of npm alerts is not a blanket guarantee.

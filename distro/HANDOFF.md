# Handoff: ariadnev-greeter packaging cutover + `advs-greeter-git`

**Audience:** next agent / human continuing packaging work  
**Repo focus:** [`bavanchun/ariadnev-greeter`](https://github.com/bavanchun/ariadnev-greeter)  
**Related:** `ariadnev`, `ariadnev-docs`, `advs` (AriadnevShell)  
**Status as of:** 2026-07-20 (evening)

---

## CRITICAL — Git / commit hard-stops

**Do not commit, amend, push, force-push, or create PRs unless the user explicitly asks in the current message.**

| Rule | Detail |
|------|--------|
| No agent commits | User rules forbid `git commit` / `git push` unless explicitly requested. Treat as hard. |
| No Co-authored-by | Never add Cursor / agent trailers. |
| No secrets in-repo | Do **not** recreate secrets notes files. Secret **names** only in chat / this handoff. |
| Review before publish | Leave packaging edits for the user to review. Summarize diffs; do not land them. |

**Incident (cleaned):** An earlier agent committed + pushed secrets notes + `Co-authored-by: Cursor`. Tip rewritten to `3c39dea`. Do not repeat.

---

## Goal

1. Greeter packaging origin is **ariadnev-greeter**, not ADVS.  
2. Packages publish into **ariadnev** channels (Copr / OBS / PPA / Void R2).  
3. Stable `advs-greeter` stays live; **`advs-greeter-git`** is a separate package (Provides + Conflicts `advs-greeter`, same `/usr/bin/advs-greeter`).  
4. Prove cutover on every channel, then push + prove GitHub Actions secrets.

---

## Where we are (summary)

| Layer | Status |
|-------|--------|
| **In-tree packaging** for `advs-greeter-git` (Fedora, OBS openSUSE+Debian, Ubuntu PPA, Void) | **Done locally / uncommitted** |
| **Workflows** unified dropdowns (`advs-greeter` \| `advs-greeter-git` \| `both`) | **Done locally / uncommitted** |
| **ariadnev-greeter GitHub Actions secrets** | **User reports all set** |
| **Docs** (ariadnev-docs install tabs + ariadnev-greeter README) | **Updated ahead of publish** (docs repo may have its own uncommitted/staged set) |
| **Copr** `advs-greeter-git` | Package exists; earlier build succeeded |
| **OBS** `advs-greeter-git` | Package **created**; first upload had Debian fail; **fixed in tree but rebuild not uploaded yet** |
| **PPA** `advs-greeter-git` | Packaging ready; **upload not started** |
| **Void R2** `advs-greeter-git` | Template ready; **build/publish not started** |
| **Commit / push of this work** | **Not done** — waiting on user |

---

## What is done (detail)

### Fedora / Copr

- Specs: `distro/fedora/advs-greeter.spec` + `advs-greeter-git.spec` (mutual Conflicts).  
- Scripts: `copr-upload.sh` (unified; `advs-greeter` \| `advs-greeter-git`; empty-tag fallback → `1.0.0+git…`).  
- Workflow: `.github/workflows/run-copr.yml` (dropdown; deleted `run-copr-git.yml` + `copr-upload-git.sh`).  
- Copr project `avengemedia/ariadnev` already has both package names.  
- Prior proof build: [10748722](https://copr.fedorainfracloud.org/coprs/build/10748722).

### OBS (openSUSE + Debian)

- Specs/trees: `distro/opensuse/advs-greeter-git.spec`, `distro/debian/advs-greeter-git/`.  
- Stable openSUSE/Debian: `Conflicts: advs-greeter-git`.  
- Script: `obs-upload.sh` supports `advs-greeter` \| `advs-greeter-git`; creates OBS package if missing; packs checkout + submodule + `go mod vendor`; Python spec rewriter (sed broke on `+` in git versions).  
- Workflow: `run-obs.yml` dropdown + submodules + Go for vendoring.  
- **Live OBS:** `home:bavanchun:ariadnev/advs-greeter-git` **exists**.  
- **First local upload** (`1.0.0+git9.d73d3c04`): openSUSE arches **succeeded**; **Debian_13 failed** because `dh_auto_test` ran `make test` without bundled Go on `PATH`.  
- **Fix in tree (not re-uploaded):** `override_dh_auto_test` on Debian (+ Ubuntu) `debian/rules` for greeter and greeter-git.  
- Rebuild CLI: bare integer or `--rebuild=N` — e.g.  
  `./distro/scripts/obs-upload.sh advs-greeter-git 2`

### Ubuntu PPA

- Tree: `distro/ubuntu/advs-greeter-git/` (Provides/Conflicts/Replaces; packs `advs-greeter-git-source/` with vendor + AdvCommon).  
- Stable Ubuntu: `Conflicts: advs-greeter-git` + `override_dh_auto_test`.  
- Script: `ppa-upload.sh [advs-greeter|advs-greeter-git] [series] [ppa_num]`.  
- Workflow: `run-ppa.yml` package dropdown including `both`.  
- **GPG:** local key imported (`F16508F357F99EE9`); signing works.  
- **Upload abort (fixed):** `yes | debuild` under `pipefail` exited 141 after sign — now `debuild … </dev/null`.  
- **Launchpad:** amd64 **succeeded**; arm64 **failed** (~11m, no build log — mid `go build`). Aligned git PPA with **advcalendar-git** blueprint: bundle `.go-toolchain` in `ppa-upload.sh`, `PATH` in `debian/rules`, `Architecture: any`, drop bogus `include-binaries`. Re-upload with bumped ppa number to prove arm64.

### Void XBPS / R2

- Template: `distro/void/srcpkgs/advs-greeter-git/` (`conflicts`/`provides`; CI stages tarball).  
- Stable Void: `conflicts="advs-greeter-git"`.  
- Workflow: `run-xbps.yml` supports greeter / git / both; `R2_PREFIX=advs` unchanged.  
- **No Void git build/publish yet.**

### Docs / README

- `ariadnev-docs` `docs/advgreeter/installation.mdx`: stable/git tabs for Fedora, Debian, Ubuntu, openSUSE, Void (written ahead of channel publish — user will push when verified).  
- `ariadnev/index.mdx` (staged earlier): lists `advs-greeter` + `advs-greeter-git`.  
- ariadnev-greeter `README.md`: mentions git install on OBS/PPA/Void/Copr.

### Secrets (names only — values in GitHub UI)

User has populated ariadnev-greeter Actions secrets. Names:

`COPR_LOGIN`, `COPR_TOKEN`, `OBS_USERNAME`, `OBS_PASSWORD`, `GPG_PRIVATE_KEY`, `LAUNCHPAD_SSH_PRIVATE_KEY`, `LAUNCHPAD_SSH_LOGIN`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `CLOUDFLARE_ACCOUNT_ID`, `XBPS_PRIVATE_KEY`, `APP_ID`, `APP_PRIVATE_KEY`

- `COPR_LOGIN` = opaque API `login=` value only (not username; workflow hardcodes `username = avengemedia`).  
- `GITHUB_TOKEN` = builtin; do not create as a repo secret.  
- Local key backup zip: `~/Downloads/API_SSH_Keys.zip` (encrypted ariadnev migration archive) + `~/Downloads/Projects/GPG-Keys.zip`.

### Local smoke already run

- `bash -n` on all `distro/scripts/*.sh`  
- OBS-style pack + vendor (~11M)  
- Fedora git SRPM built locally (not necessarily re-uploaded)  
- OBS package create + first upload (Debian fail as above)

---

## Architecture (target)

```text
ariadnev-greeter (source + packaging + CI)
    │
    ├── Copr  → avengemedia/ariadnev
    │             ├── advs-greeter
    │             └── advs-greeter-git      ← live earlier; keep healthy
    ├── OBS   → home:bavanchun:ariadnev
    │             ├── advs-greeter          ← stable live
    │             └── advs-greeter-git      ← created; needs Debian-fix rebuild upload
    ├── PPA   → ppa:avengemedia/ariadnev
    │             ├── advs-greeter          ← stable
    │             └── advs-greeter-git      ← packaging ready; not uploaded
    └── Void  → void.ariadnev.vchun.dev/advs/current
                  ├── advs-greeter
                  └── advs-greeter-git      ← packaging ready; not published
```

Binary for all: `/usr/bin/advs-greeter`.

---

## Next agent goal — publish + verify (do not commit unless asked)

Packaging code is largely ready. Remaining work is **upload/build proof**, then user commit/push, then **Actions secret proof**.

### Suggested order

1. **OBS rebuild with Debian fix** (local, uses `~/.config/osc`):  
   `./distro/scripts/obs-upload.sh advs-greeter-git 2`  
   Then `./distro/scripts/obs-status.sh advs-greeter-git` until Debian_13 + openSUSE green.

2. **PPA git** (local first if GPG + Launchpad ready):  
   `./distro/scripts/ppa-upload.sh advs-greeter-git resolute`  
   Watch Launchpad builds.

3. **Void git** — after push or via Actions `run-xbps.yml` with `advs-greeter-git` (needs R2/XBPS secrets in CI). Local xbps-src optional.

4. **User review + commit + push** all ariadnev-greeter packaging/workflow changes (and docs when ready).

5. **Prove GitHub secrets** via `workflow_dispatch`:  
   - `run-copr.yml` → `advs-greeter-git`  
   - `run-obs.yml` → `advs-greeter-git`  
   - `run-ppa.yml` → `advs-greeter-git`  
   - `run-xbps.yml` → `advs-greeter-git`  
   Local scripts prove local creds/builds; **only Actions prove repo secrets**.

6. **Docs:** already drafted for git installs; only push/publish docs once channels actually ship (or keep as-is per user preference to ship together).

### Design constraints (unchanged)

- Package name `advs-greeter-git`; mutual Conflicts; Prefer Provides `advs-greeter`.  
- Pack `ariadnev-qml-common`; restore `quickshell/AdvCommon` symlink.  
- OBS Debian/openSUSE: offline → vendor + bundled Go.  
- PPA: distro `golang-go` + vendored tree in native source.  
- Void: `R2_PREFIX=advs`; coordinate with advs Void publishes.  
- Do not force-republish stable unless asked.

### Gotchas already hit

| Issue | Fix |
|-------|-----|
| `sed` dies on Version `1.0.0+git…` in `obs-upload.sh` | Python rewriter in `update_opensuse_git_spec` |
| `GO_VER=$(stage_go_toolchains)` polluted by stdout logs | Status → stderr; validate version token |
| OBS Debian `go: not found` in `dh_auto_test` | `override_dh_auto_test` in debian/ubuntu rules |
| `ppa-upload.sh advs-greeter-git` was unknown | Script now accepts package name |
| (was) bare `2` ignored as message | Fixed: bare integer sets rebuild; `--rebuild=N` still works |
| Empty `git describe` (no tags) | Fallback base `1.0.0` |
| PPA `yes \| debuild` → exit 141 after sign | Drop `yes`; `debuild … </dev/null` |

### Reference files

- Fedora: `distro/fedora/advs-greeter-git.spec`, `distro/scripts/copr-upload.sh`  
- OBS: `distro/opensuse/advs-greeter-git.spec`, `distro/debian/advs-greeter-git/`, `distro/scripts/obs-upload.sh`  
- PPA: `distro/ubuntu/advs-greeter-git/`, `distro/scripts/ppa-upload.sh`  
- Void: `distro/void/srcpkgs/advs-greeter-git/`, `.github/workflows/run-xbps.yml`  
- Workflows: `.github/workflows/run-{copr,obs,ppa,xbps}.yml`

---

## Verification checklist

- [ ] User reviewed/committed packaging + workflow changes  
- [ ] OBS `advs-greeter-git` rebuild uploaded; Debian_13 + openSUSE all green  
- [ ] PPA `advs-greeter-git` uploaded and Launchpad build succeeded  
- [ ] Void `advs-greeter-git` built and published to `void.ariadnev.vchun.dev/advs/current`  
- [ ] Actions dispatch proves Copr/OBS/PPA/Void secrets on ariadnev-greeter  
- [ ] `dnf` / `apt` / `zypper` / `xbps-install` git install paths work  
- [ ] No secrets markdown or Co-authored-by in agent-touched commits  
- [ ] Docs pushed only when channels match documented install steps (or intentionally ahead)

---

## Out of scope (still)

- AUR `greetd-advs-greeter-git` / `-bin` (external).  
- Republishing stable greeter until next tag (unless user asks).  
- Changing Void `R2_PREFIX` away from `advs`.

---

## Handoff one-liner

**In-tree `advs-greeter-git` packaging for Copr/OBS/PPA/Void is ready locally (uncommitted); OBS package exists but needs rebuild `2` after the Debian `dh_auto_test` fix; PPA and Void git uploads not started; secrets are in GitHub — prove them with Actions after user push; do not commit unless asked.**

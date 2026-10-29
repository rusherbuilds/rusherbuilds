#!/usr/bin/env bash
# Safe, opt-in GitHub profile repository publisher.
# Preview: bash scripts/APPLY_LINUX_MAC.sh --dry-run
# Publish: bash scripts/APPLY_LINUX_MAC.sh (then type APPLY)
set -euo pipefail

USERNAME='rusherbuilds'
REPO="$USERNAME/$USERNAME"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANAGED=(README.md .github assets docs scripts tests START_HERE_AR.md DEPLOY_COMMANDS_AR.md LICENSE.md .gitignore)
DRY_RUN=false

if [[ "$#" -gt 1 ]] || { [[ "$#" -eq 1 ]] && [[ "${1}" != '--dry-run' ]]; }; then
  echo "Usage: bash scripts/APPLY_LINUX_MAC.sh [--dry-run]" >&2
  exit 2
fi
[[ "$#" -eq 0 ]] || DRY_RUN=true

for cmd in git gh; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing dependency: $cmd" >&2; exit 1; }
done
for entry in "${MANAGED[@]}"; do
  [[ -e "$ROOT/$entry" ]] || { echo "Missing package entry: $entry" >&2; exit 1; }
done

if ! CURRENT="$(gh api user --jq '.login')"; then
  echo "GitHub login required: gh auth login -h github.com" >&2
  exit 1
fi
if [[ "$CURRENT" != "$USERNAME" ]]; then
  echo "Wrong GitHub account ($CURRENT); expected $USERNAME. Nothing changed." >&2
  exit 1
fi

# A network/permission failure must never be mistaken for an absent repository.
EXISTS=false
if VISIBILITY="$(gh api "repos/$REPO" --jq '.visibility' 2>&1)"; then
  EXISTS=true
  if [[ "$VISIBILITY" != public ]]; then
    echo "Existing repository is $VISIBILITY; refusing to change its visibility. Make it public manually if intended." >&2
    exit 1
  fi
elif [[ "$VISIBILITY" != *'HTTP 404'* ]]; then
  printf 'Could not inspect %s: %s\n' "$REPO" "$VISIBILITY" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
CLONE="$TMP/repo"

stage_package() {
  local entry
  for entry in "${MANAGED[@]}"; do
    # Merge managed subtrees, preserving unrelated files in an existing repo.
    cp -R "$ROOT/$entry" "$CLONE/"
  done
  git -C "$CLONE" add -- "${MANAGED[@]}"
}

echo "Signed in as: $CURRENT"
echo "Target: https://github.com/$REPO"
echo "Managed package paths: ${MANAGED[*]}"
echo "Unrelated repositories and files are untouched. No force pushes."

if [[ "$EXISTS" == true ]]; then
  git clone "https://github.com/$REPO.git" "$CLONE"
  stage_package
  echo 'Staged change preview:'
  git -C "$CLONE" diff --cached --stat
  if git -C "$CLONE" diff --cached --quiet; then
    echo 'Already up to date. Nothing to publish.'
    exit 0
  fi
else
  echo "The public repository $REPO does not exist. It will be created ONLY after confirmation."
  printf 'New repository files:\n'
  printf '  %s\n' "${MANAGED[@]}"
fi

if [[ "$DRY_RUN" == true ]]; then
  echo 'DRY RUN COMPLETE: no remote files or repositories changed.'
  exit 0
fi

printf 'Type APPLY to create/update %s: ' "$REPO"
read -r answer
if [[ "$answer" != APPLY ]]; then
  echo 'Cancelled. Nothing was published.'
  exit 0
fi

if [[ "$EXISTS" == false ]]; then
  gh repo create "$REPO" --public --add-readme --description 'Animated GitHub profile and engineering portfolio'
  git clone "https://github.com/$REPO.git" "$CLONE"
  stage_package
elif [[ -f "$CLONE/README.md" ]]; then
  mkdir -p "$ROOT/backups"
  BACKUP="$ROOT/backups/README_BACKUP_$(date +%Y%m%d_%H%M%S)_$RANDOM.md"
  git -C "$CLONE" show HEAD:README.md > "$BACKUP"
  echo "Original README backed up locally to: $BACKUP"
fi

if git -C "$CLONE" diff --cached --quiet; then
  echo 'Already up to date.'
  exit 0
fi

GITHUB_ID="$(gh api user --jq '.id')"
[[ "$GITHUB_ID" =~ ^[0-9]+$ ]] || { echo 'Could not verify numeric GitHub account ID' >&2; exit 1; }
git -C "$CLONE" config user.name "$CURRENT"
git -C "$CLONE" config user.email "${GITHUB_ID}+${CURRENT}@users.noreply.github.com"
git -C "$CLONE" commit -m 'Enhance GitHub profile and portfolio'
git -C "$CLONE" push origin HEAD
echo "Published: https://github.com/$USERNAME"
echo 'Next: Run Build contribution arcade in Actions; enable GitHub Pages on the default branch /docs.'

#!/usr/bin/env bash

set -euo pipefail

PROGRAM=${0##*/}

usage() {
  cat <<'EOF'
Usage:
  dev/branch_commit.sh -m MESSAGE [--all | --interactive | -- PATH...]
  dev/branch_commit.sh --install

Commit staged changes through the iEDA.ai branch policy. If nothing is staged,
the script opens interactive staging when attached to a terminal.

Options:
  -m, --message MESSAGE     Commit message. The branch lane prefix is added.
  -a, --all                 Stage all lane-appropriate changes.
  -p, --interactive         Interactively stage tracked changes.
      --allow-cross-lane    Allow an exceptional cross-lane change.
      --no-tests            Skip the lane verification command, if configured.
      --install             Install repository hooks and the git alias.
  -h, --help                Show this help.

Examples:
  dev/branch_commit.sh -m "improve incremental STA" -- src/operation/iSTA
  dev/branch_commit.sh -a -m "add QoR regression"
  git branch-commit -m "add typed capability response" --all

Optional verification commands:
  IEDA_PARITY_VERIFY_CMD='ctest --test-dir build-parity'
  IEDA_AGENT_VERIFY_CMD='ctest --test-dir build-agent'
  IEDA_COMPAT_VERIFY_CMD='./path/to/shared-regression.sh'
EOF
}

fail() {
  printf '%s: %s\n' "$PROGRAM" "$*" >&2
  exit 1
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a Git worktree"
cd "$repo_root"

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || fail "detached HEAD is not allowed"

case "$branch" in
  commercial-parity | feat/parity-* | fix/parity-* | perf/parity-* | test/parity-* | wip/parity-*)
    lane=parity
    ;;
  integration/agent-native | feat/agent-* | fix/agent-* | perf/agent-* | test/agent-* | wip/agent-*)
    lane=agent
    ;;
  compat/*)
    lane=compat
    ;;
  main)
    fail "direct commits to main are prohibited; use commercial-parity, integration/agent-native, or compat/*"
    ;;
  *)
    fail "unsupported branch '$branch'; use a parity, agent, or compat branch name"
    ;;
esac

message=
stage_mode=staged
allow_cross_lane=0
run_tests=1
hook_mode=
message_file=
install=0
declare -a paths=()

while (($#)); do
  case "$1" in
    -m | --message)
      (($# >= 2)) || fail "$1 requires a value"
      message=$2
      shift 2
      ;;
    -a | --all)
      [[ $stage_mode == staged ]] || fail "choose only one staging mode"
      stage_mode=all
      shift
      ;;
    -p | --interactive)
      [[ $stage_mode == staged ]] || fail "choose only one staging mode"
      stage_mode=interactive
      shift
      ;;
    --allow-cross-lane)
      allow_cross_lane=1
      shift
      ;;
    --no-tests)
      run_tests=0
      shift
      ;;
    --install)
      install=1
      shift
      ;;
    --hook-check)
      hook_mode=check
      shift
      ;;
    --hook-message)
      (($# >= 2)) || fail "$1 requires a commit message file"
      hook_mode=message
      message_file=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      paths+=("$@")
      break
      ;;
    -*)
      fail "unknown option '$1'"
      ;;
    *)
      paths+=("$1")
      shift
      ;;
  esac
done

if ((install)); then
  [[ -z $hook_mode && -z $message && ${#paths[@]} -eq 0 ]] || fail "--install cannot be combined with commit options"
  git config core.hooksPath .githooks
  git config alias.branch-commit '!./dev/branch_commit.sh'
  printf 'Installed core.hooksPath=.githooks and git branch-commit alias.\n'
  exit 0
fi

is_generated_path() {
  case "$1" in
    build/* | build-*/* | cmake-build-*/* | */CMakeFiles/* | */__pycache__/* | *.pyc | *.pyo)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_agent_owned_path() {
  case "$1" in
    docs/ai/* | docs/ai1.0/* | docs/agent/* | src/ai/agent*/* | src/platform/design_state/* | src/platform/agent_*/* | src/platform/flow/tool_flow/* | src/interface/mcp-iEDA/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_core_kernel_path() {
  case "$1" in
    src/database/* | src/evaluation/* | src/operation/* | src/solver/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_staged() {
  git diff --quiet --diff-filter=U || fail "resolve all merge conflicts before committing"
  git diff --cached --quiet && fail "nothing is staged"
  git diff --cached --check

  local path
  local -a generated=()
  local -a cross_lane=()
  while IFS= read -r -d '' path; do
    # Deleting a previously tracked generated artifact is allowed.
    if is_generated_path "$path" && git cat-file -e ":$path" 2>/dev/null; then
      generated+=("$path")
    fi

    if ((allow_cross_lane == 0)) && [[ ${IEDA_COMMIT_ALLOW_CROSS_LANE:-0} != 1 ]]; then
      if [[ $lane == parity ]] && is_agent_owned_path "$path"; then
        cross_lane+=("$path")
      elif [[ $lane == agent ]] && is_core_kernel_path "$path"; then
        cross_lane+=("$path")
      fi
    fi
  done < <(git diff --cached --name-only -z --diff-filter=ACMRTUXB)

  if ((${#generated[@]})); then
    printf 'Generated files must not be committed:\n' >&2
    printf '  %s\n' "${generated[@]}" >&2
    fail "unstage these files and use an out-of-tree build directory"
  fi

  if ((${#cross_lane[@]})); then
    printf 'Cross-lane files require a compat/* branch or explicit review:\n' >&2
    printf '  %s\n' "${cross_lane[@]}" >&2
    fail "move the change to compat/*, or rerun with --allow-cross-lane"
  fi
}

run_lane_verification() {
  ((run_tests)) || return 0
  [[ ${IEDA_COMMIT_TESTS_DONE:-0} != 1 ]] || return 0

  local command=
  case "$lane" in
    parity) command=${IEDA_PARITY_VERIFY_CMD:-} ;;
    agent) command=${IEDA_AGENT_VERIFY_CMD:-} ;;
    compat) command=${IEDA_COMPAT_VERIFY_CMD:-} ;;
  esac

  if [[ -n $command ]]; then
    printf 'Running %s verification: %s\n' "$lane" "$command"
    bash -lc "$command"
  fi
}

validate_message() {
  local candidate=$1
  local first_line
  first_line=$(printf '%s\n' "$candidate" | sed -n '/^[[:space:]]*#/d; /^[[:space:]]*$/d; 1p')
  [[ -n $first_line ]] || fail "commit message is empty"

  if [[ $first_line =~ ^(parity|agent|compat)(\([^\)]+\))?:[[:space:]]+ ]]; then
    [[ ${BASH_REMATCH[1]} == "$lane" ]] || fail "commit prefix '${BASH_REMATCH[1]}' does not match '$lane' branch"
  else
    fail "commit message must start with '$lane:' or '$lane(scope):'"
  fi
}

if [[ $hook_mode == check ]]; then
  validate_staged
  run_lane_verification
  exit 0
fi

if [[ $hook_mode == message ]]; then
  # Merge commits keep Git's generated message; branch ownership was checked by pre-commit.
  if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    exit 0
  fi
  [[ -f $message_file ]] || fail "cannot read commit message file '$message_file'"
  validate_message "$(<"$message_file")"
  exit 0
fi

if ((${#paths[@]})); then
  [[ $stage_mode == staged ]] || fail "explicit paths cannot be combined with --all or --interactive"
  git add -A -- "${paths[@]}"
elif [[ $stage_mode == all ]]; then
  declare -a excludes=(
    ':(exclude,glob)build/**'
    ':(exclude,glob)build-*/**'
    ':(exclude,glob)cmake-build-*/**'
    ':(exclude,glob)**/CMakeFiles/**'
    ':(exclude,glob)**/__pycache__/**'
  )
  if [[ $lane == parity ]]; then
    excludes+=(
      ':(exclude,glob)docs/ai1.0/**'
      ':(exclude,glob)docs/ai/**'
      ':(exclude,glob)docs/agent/**'
      ':(exclude,glob)src/ai/agent*/**'
      ':(exclude,glob)src/platform/design_state/**'
      ':(exclude,glob)src/platform/agent_*/**'
      ':(exclude,glob)src/platform/flow/tool_flow/**'
      ':(exclude,glob)src/interface/mcp-iEDA/**'
    )
  elif [[ $lane == agent ]]; then
    excludes+=(
      ':(exclude,glob)src/database/**'
      ':(exclude,glob)src/evaluation/**'
      ':(exclude,glob)src/operation/**'
      ':(exclude,glob)src/solver/**'
    )
  fi
  git add -A -- . "${excludes[@]}"
elif [[ $stage_mode == interactive ]]; then
  git add -p
elif git diff --cached --quiet; then
  if [[ -t 0 && -t 1 ]]; then
    git add -p
  else
    fail "nothing is staged; pass --all, --interactive, or explicit paths after --"
  fi
fi

validate_staged
run_lane_verification

[[ -n $message ]] || fail "provide a commit message with -m/--message"
if [[ $message =~ ^(parity|agent|compat)(\([^\)]+\))?:[[:space:]]+ ]]; then
  normalized_message=$message
else
  normalized_message="$lane: $message"
fi
validate_message "$normalized_message"

printf 'Branch: %s\nLane:   %s\nCommit: %s\nFiles:\n' "$branch" "$lane" "$normalized_message"
git diff --cached --name-status

IEDA_COMMIT_ALLOW_CROSS_LANE=$allow_cross_lane \
IEDA_COMMIT_TESTS_DONE=1 \
  git commit -m "$normalized_message"

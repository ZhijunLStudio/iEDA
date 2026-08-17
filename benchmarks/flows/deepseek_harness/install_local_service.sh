#!/usr/bin/env bash
# Register the iEDA GP native bundle into a locally installed dsh profile and
# restart the systemd web service when present.
#
# This is the route for an installed `@deepseek-ai/dsh` CLI (rc.6):
#   dsh plugin --profile <name> add <this-package>
# The package declares `dsh.bundle.patch`, so `dsh plugin` reconciles it into
# the profile's bundle list automatically.
set -euo pipefail

DSH_PROFILE="${DSH_PROFILE:-web}"
IEDA_ROOT_DEFAULT="${IEDA_ROOT:-/home/lizhijun/work/iEDA.ai}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$HERE/profile_plugin"
GLOBAL_DSH="${GLOBAL_DSH:-$HOME/.npm-global/lib/node_modules/@deepseek-ai/dsh}"

# Local bootstrap for dependency resolution when npm registry access is
# unavailable: the running dsh CLI already ships both runtime packages.
mkdir -p "$PLUGIN/node_modules/@deepseek-ai"
ln -sfn "$GLOBAL_DSH/node_modules/@deepseek-ai/dsh-tools" \
  "$PLUGIN/node_modules/@deepseek-ai/dsh-tools"
ln -sfn "$GLOBAL_DSH/node_modules/@deepseek-ai/schemastery" \
  "$PLUGIN/node_modules/@deepseek-ai/schemastery"

# pnpm shim location used by this machine (dsh plugin forwards to `pnpm`).
PATH="$HOME/.npm-global/bin:$HERE/../../../..:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
if [ ! -x "$HOME/.npm-global/bin/dsh" ]; then
  echo "dsh CLI not found under $HOME/.npm-global/bin" >&2
  exit 1
fi

dsh plugin --profile "$DSH_PROFILE" add "$PLUGIN"

if [ "$DSH_PROFILE" = "web" ] && systemctl --user is-active dsh-web.service >/dev/null 2>&1; then
  systemctl --user restart dsh-web.service
  echo "restarted dsh-web.service"
fi
echo "registered @ieda-ai/dsh-tool-ieda-gp into dsh profile '$DSH_PROFILE'"

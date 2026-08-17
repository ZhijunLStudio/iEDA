#!/usr/bin/env bash
# Register the iEDA GP native bundle into a locally installed dsh profile.
# 缺省不重启 dsh-web.service（重启会打断正在执行的 agent 工具调用）：
# 运行中的 bundle 变更由 dsh-super-injector 的 watch 自动热重载；
# 确需重启时显式加 --restart。
#
# This is the route for an installed `@deepseek-ai/dsh` CLI (rc.6):
#   dsh plugin --profile <name> add <this-package>
# The package declares `dsh.bundle.patch`, so `dsh plugin` reconciles it into
# the profile's bundle list automatically.
set -euo pipefail

DSH_PROFILE="${DSH_PROFILE:-web}"
RESTART=0
for arg in "$@"; do
  case "$arg" in
    --restart) RESTART=1 ;;
    --no-restart) RESTART=0 ;;
  esac
done
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
  if [ "$RESTART" = "1" ]; then
    systemctl --user restart dsh-web.service
    echo "restarted dsh-web.service"
  else
    echo "dsh-web.service 保持运行（未重启）。插件 lib 已变更："
    echo "  - super-injector watch 会在 ~1.5s 内自动热重载（watch 配置于下次服务启动后生效）"
    echo "  - 或立即热重载：GUI 会话里让 agent 执行 dev_reload_package '@ieda-ai/dsh-tool-ieda-gp'"
    echo "  - 或显式重启：重新运行本脚本并加 --restart"
  fi
fi
echo "registered @ieda-ai/dsh-tool-ieda-gp into dsh profile '$DSH_PROFILE'"

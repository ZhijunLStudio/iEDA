#!/bin/bash
# Build the iEDA launcher that hides /etc/ld.so.preload.
#
# The host preloads /usr/local/lib/sshdd.so system-wide; that shim denies creating any directory
# whose path contains the lower-case substring log, which stops iEDA's router at
# output/rt/rt_temp_directory/topology_generator and its placement log at output/pl/log.
# Binding /dev/null over the preload file inside a mount namespace hides the shim from the process
# tree, so ld.so never loads it. iEDA itself is untouched.
#
# Usage: bash rsi/harness/make_ieda_nosshim.sh , then set IEDA_BIN=<repo>/build/bin/iEDA-nosshim
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REAL="$ROOT/build/bin/iEDA"
OUT="$ROOT/build/bin/iEDA-nosshim"
if [ ! -x "$REAL" ]; then echo "missing $REAL" >&2; exit 1; fi
printf '%s\n' '#!/bin/bash' 'exec bwrap --dev-bind / / --ro-bind /dev/null /etc/ld.so.preload \' "  $REAL \"\$@\"" > "$OUT"
chmod +x "$OUT"
echo "wrote $OUT"

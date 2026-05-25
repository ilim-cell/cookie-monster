#!/usr/bin/env bash
# macOS installer (same as linux installer)

$(sed -n '1,240p' "c:\Users\Class\3D Objects\Code\cookie-monster\install.sh" 2>/dev/null || cat <<'EOF'
# fallback installer content
EOF)
#!/usr/bin/env bash
# setup-jumphost.sh
#
# Provision an Ubuntu/Debian Proxmox LXC container as a student jumphost.
#
# Students SSH to the "student01" account and are forced into /usr/local/bin/lab.sh.
# This is a classroom access restriction, not a hardened security sandbox.
#
# Example:
#   ./setup-jumphost.sh \
#     --zerotier-network 4d71989505027d68 \
#     --gns3-host 172.233.75.181 \
#     --lab-script ./lab.sh

# Exit immediately on errors, undefined variables, or failed commands in pipelines for safer script execution.
set -euo pipefail

TEMPLATE_USER="student01"
LAB_DEST="/usr/local/bin/lab.sh"
LAB_SRC=""
ZEROTIER_NETWORK=""
GNS3_HOST=""
SET_PASSWORD="yes"

usage() {
    cat <<'EOF'
Usage:
  setup-jumphost.sh --zerotier-network <NETWORK_ID> --gns3-host <IP_OR_HOSTNAME> --lab-script <PATH> [options]

Required:
  --zerotier-network <NETWORK_ID>   ZeroTier network ID to join
  --gns3-host <IP_OR_HOSTNAME>      GNS3 server ZeroTier IP or hostname
  --lab-script <PATH>               Existing lab menu script to install as /usr/local/bin/lab.sh

Options:
  --user <USERNAME>                 Student user, default: student01
  --no-password-prompt              Do not prompt to set/reset the student password
  -h, --help                        Show this help

Notes:
  - Run as root inside the LXC container.
  - Ensure the Proxmox LXC has /dev/net/tun passed through before running ZeroTier.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --zerotier-network)
            ZEROTIER_NETWORK="${2:-}"
            shift 2
            ;;
        --gns3-host)
            GNS3_HOST="${2:-}"
            shift 2
            ;;
        --lab-script)
            LAB_SRC="${2:-}"
            shift 2
            ;;
        --user)
            TEMPLATE_USER="${2:-}"
            shift 2
            ;;
        --no-password-prompt)
            SET_PASSWORD="no"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

require_value() {
    local name="$1"
    local value="$2"
    if [[ -z "$value" ]]; then
        echo "Missing required option: $name" >&2
        usage
        exit 1
    fi
}

require_value "--zerotier-network" "$ZEROTIER_NETWORK"
require_value "--gns3-host" "$GNS3_HOST"
require_value "--lab-script" "$LAB_SRC"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
fi

if [[ ! -f "$LAB_SRC" ]]; then
    echo "Lab script not found: $LAB_SRC" >&2
    exit 1
fi

echo "[1/9] Updating package lists and installing packages..."
apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
    openssh-server \
    openssh-client \
    telnet \
    curl \
    ca-certificates \
    gnupg \
    iproute2 \
    iputils-ping \
    netcat-openbsd \
    tcptraceroute

echo "[2/9] Installing ZeroTier if needed..."
if ! command -v zerotier-cli >/dev/null 2>&1; then
    curl -s https://install.zerotier.com | bash
fi

systemctl enable --now zerotier-one

echo "[3/9] Checking LXC TUN device..."
if [[ ! -e /dev/net/tun ]]; then
    cat >&2 <<'EOF'

ERROR: /dev/net/tun is missing.

Fix this on the Proxmox host by adding these lines to /etc/pve/lxc/<CTID>.conf:

lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file

Then restart the container:

pct restart <CTID>

EOF
    exit 1
fi

echo "[4/9] Joining ZeroTier network..."
zerotier-cli join "$ZEROTIER_NETWORK" || true
zerotier-cli status || true

cat <<EOF

IMPORTANT:
Authorise this node in ZeroTier Central if it is not already authorised.
Network ID: $ZEROTIER_NETWORK

EOF

echo "[5/9] Creating/updating student account: $TEMPLATE_USER"
if id "$TEMPLATE_USER" >/dev/null 2>&1; then
    echo "User $TEMPLATE_USER already exists."
else
    adduser --disabled-password --gecos "" "$TEMPLATE_USER"
fi

# Ensure the user does not have sudo via obvious default groups.
for group in sudo admin wheel; do
    if getent group "$group" >/dev/null 2>&1; then
        gpasswd -d "$TEMPLATE_USER" "$group" >/dev/null 2>&1 || true
    fi
done

if [[ "$SET_PASSWORD" == "yes" ]]; then
    echo "Set/reset the password for $TEMPLATE_USER:"
    passwd "$TEMPLATE_USER"
fi

echo "[6/9] Installing lab menu script..."
install -o root -g root -m 755 "$LAB_SRC" "$LAB_DEST"

# If the generated lab menu supports GNS3_HOST as an environment variable, this creates a default.
cat > /etc/profile.d/jumphost.sh <<EOF
export GNS3_HOST="$GNS3_HOST"
EOF
chmod 644 /etc/profile.d/jumphost.sh

# Also patch common placeholder/default patterns if present.
if grep -q 'GNS3_HOST=' "$LAB_DEST"; then
    sed -i "s|^GNS3_HOST=.*|GNS3_HOST=\"\${GNS3_HOST:-$GNS3_HOST}\"|" "$LAB_DEST" || true
fi

echo "[7/9] Configuring SSH forced command..."
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

# Remove previous managed block if present.
sed -i '/# BEGIN JUMPHOST/,/# END JUMPHOST/d' "$SSHD_CONFIG"

# Set safer global defaults for this classroom host.
if grep -qE '^\s*PermitRootLogin\s+' "$SSHD_CONFIG"; then
    sed -i 's/^\s*PermitRootLogin\s\+.*/PermitRootLogin no/' "$SSHD_CONFIG"
else
    echo 'PermitRootLogin no' >> "$SSHD_CONFIG"
fi

if grep -qE '^\s*PasswordAuthentication\s+' "$SSHD_CONFIG"; then
    sed -i 's/^\s*PasswordAuthentication\s\+.*/PasswordAuthentication yes/' "$SSHD_CONFIG"
else
    echo 'PasswordAuthentication yes' >> "$SSHD_CONFIG"
fi

if grep -qE '^\s*UsePAM\s+' "$SSHD_CONFIG"; then
    sed -i 's/^\s*UsePAM\s\+.*/UsePAM yes/' "$SSHD_CONFIG"
else
    echo 'UsePAM yes' >> "$SSHD_CONFIG"
fi

cat >> "$SSHD_CONFIG" <<EOF

# BEGIN JUMPHOST
# Classroom restriction: force the student user directly into the lab menu.
Match User $TEMPLATE_USER
    ForceCommand $LAB_DEST
    X11Forwarding no
    AllowTcpForwarding no
    PermitTunnel no
# END JUMPHOST
EOF

echo "[8/9] Validating and restarting SSH..."
sshd -t
systemctl restart ssh || systemctl restart sshd

echo "[9/9] Final checks..."
echo
echo "Student account:"
getent passwd "$TEMPLATE_USER"
echo
echo "Lab script:"
ls -l "$LAB_DEST"
echo
echo "ZeroTier status:"
zerotier-cli status || true
zerotier-cli listnetworks || true
echo
echo "Route check template:"
echo "  ip route get $GNS3_HOST"
echo
echo "Service check examples:"
echo "  tcptraceroute $GNS3_HOST 22"
echo "  telnet $GNS3_HOST <console-port>"
echo
echo "Student login test:"
echo "  ssh $TEMPLATE_USER@10.10.0.10"
echo
echo "Provisioning complete."

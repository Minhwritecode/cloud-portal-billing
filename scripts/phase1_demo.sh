#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v openstack >/dev/null 2>&1; then
  echo "ERROR: openstack CLI is not available on PATH."
  echo "Inside DevStack, run: source /opt/stack/devstack/openrc admin admin"
  exit 1
fi

if [[ -z "${OS_AUTH_URL:-}" && -z "${OS_CLOUD:-}" ]]; then
  echo "ERROR: authenticate first by sourcing openrc or setting OS_CLOUD."
  echo "Example: source /opt/stack/devstack/openrc admin admin"
  exit 1
fi

echo "=============================================="
echo " Cloud Portal - OpenStack Phase 1 Demo"
echo "=============================================="
echo

echo "[1/7] Keystone token"
openstack token issue
echo

echo "[2/7] OpenStack services"
openstack service list
echo

echo "[3/7] Compute services"
openstack compute service list
echo

echo "[4/7] Network agents"
openstack network agent list
echo

echo "[5/7] Images, flavors and networks"
openstack image list
openstack flavor list
openstack network list
echo

echo "[6/7] Servers"
openstack server list
echo

echo "[7/7] Python SDK connection"
if [[ -x "$PROJECT_DIR/.venv/bin/python" ]]; then
  "$PROJECT_DIR/.venv/bin/python" "$PROJECT_DIR/scripts/phase1_demo.py"
else
  python3 "$PROJECT_DIR/scripts/phase1_demo.py"
fi

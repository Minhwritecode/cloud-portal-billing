#!/usr/bin/env bash
set -euo pipefail

if ! command -v openstack >/dev/null 2>&1; then
  echo "ERROR: openstack CLI is not installed or not on PATH." >&2
  echo "Install python-openstackclient in the active environment, then source DevStack's openrc." >&2
  exit 1
fi

if [[ -z "${OS_AUTH_URL:-}" && -z "${OS_CLOUD:-}" ]]; then
  echo "ERROR: source openrc or set OS_CLOUD before running this script." >&2
  echo "Example: source /opt/stack/devstack/openrc admin admin" >&2
  exit 1
fi

echo "== Keystone token =="
openstack token issue
echo
echo "== Images =="
openstack image list
echo
echo "== Flavors =="
openstack flavor list
echo
echo "== Networks =="
openstack network list
echo
echo "== Servers =="
openstack server list
echo
echo "DevStack API verification completed."

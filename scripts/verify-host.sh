#!/usr/bin/env bash
set -euo pipefail

echo "== Host checks for DevStack VM =="
printf 'OS: '; . /etc/os-release; printf '%s %s\n' "${PRETTY_NAME:-unknown}" "${VERSION_ID:-unknown}"
printf 'Kernel: '; uname -sr
printf 'CPU cores: '; nproc
printf 'Memory: '; free -h | awk '/^Mem:/ {print $2 " total, " $7 " available"}'
printf 'Root disk: '; df -h / | awk 'NR==2 {print $2 " total, " $4 " available"}'
printf 'Hostname: '; hostname
echo
echo "== Network =="
ip -br addr
ip route
echo
echo "== Required commands =="
for command_name in git curl sudo ip awk; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf 'OK      %s -> %s\n' "$command_name" "$(command -v "$command_name")"
  else
    printf 'MISSING %s\n' "$command_name"
  fi
done
echo
echo "If this is a VMware guest, confirm the VM has bridged networking and nested virtualization enabled before installing DevStack."

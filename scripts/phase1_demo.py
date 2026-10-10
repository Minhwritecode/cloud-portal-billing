#!/usr/bin/env python3
"""Read-only Phase 1 OpenStack SDK demonstration."""

from __future__ import annotations

import argparse
import os
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prove that this machine can connect to OpenStack using openstacksdk."
    )
    parser.add_argument(
        "--cloud",
        default=os.getenv("OPENSTACK_CLOUD"),
        help="Named cloud from clouds.yaml; omit to use OS_* variables from openrc.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        import openstack
    except ImportError:
        print("ERROR: openstacksdk is not installed in the active Python environment.")
        print("Run: python -m pip install -r requirements.txt")
        return 1

    connect_options = {
        "app_name": "cloud-portal",
        "app_version": "phase-1-demo",
    }
    if args.cloud:
        connect_options["cloud"] = args.cloud

    try:
        conn = openstack.connect(**connect_options)

        # The first API request forces authentication. If credentials or the
        # endpoint are wrong, openstacksdk raises here before the demo output.
        servers = list(conn.compute.servers())
        images = list(conn.compute.images())
        flavors = list(conn.compute.flavors())
        networks = list(conn.network.networks())
    except Exception as exc:  # SDK exceptions vary by auth/network failure.
        print("AUTHENTICATION: FAILED")
        print(f"{type(exc).__name__}: {exc}")
        return 1

    print("AUTHENTICATION: OK")
    print(f"CLOUD: {args.cloud or 'OS_* environment variables'}")
    print("CONNECTION: Python openstacksdk -> OpenStack API")

    print(f"\nIMAGES ({len(images)}):")
    for image in images:
        print(f"- {image.name or image.id} [{image.status}]")

    print(f"\nFLAVORS ({len(flavors)}):")
    for flavor in flavors:
        print(f"- {flavor.name or flavor.id}: {flavor.vcpus} vCPU, {flavor.ram} MB RAM")

    print(f"\nNETWORKS ({len(networks)}):")
    for network in networks:
        print(f"- {network.name or network.id} [{network.status}]")

    print(f"\nSERVERS ({len(servers)}):")
    for server in servers:
        print(f"- {server.name or server.id} [{server.status}]")

    print("\nPHASE 1 RESULT: PASS")
    print("This demo only reads OpenStack resources; it does not create or delete anything.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

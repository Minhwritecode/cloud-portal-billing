import os


def get_connection():
    """Return an OpenStack SDK connection in real mode."""
    if os.getenv("OPENSTACK_MODE", "mock").lower() == "mock":
        return None

    import openstack

    return openstack.connect(cloud=os.getenv("OPENSTACK_CLOUD", "portal"))

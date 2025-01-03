# Reticulum Things

My reticulum scripts, configs, and other things.

## Make Commands

```bash
# Start all nodes (creates directories and copies configs/files)
make start

# Stop all nodes
make stop

# Remove everything (stops containers and removes volumes)
make remove

# Copy configs to a specific node
make copy-config NODE=3

# Copy pages to a specific node
make copy-pages NODE=3

# Copy files to a specific node
make copy-files NODE=3

# Copy to all nodes (omit NODE parameter)
make copy-config
make copy-pages
make copy-files

# Create backup of specific node
make backup NODE=3

# Create backup of all nodes
make backup
```

## NomadNet Podman Commands

```bash
# Pull the image
podman pull ghcr.io/markqvist/nomadnet:master

# Run interactively with text UI
podman run -it ghcr.io/markqvist/nomadnet:master --textui

# Run as daemon with host configs and network
podman run -d \
-v /local/path/nomadnetconfigdir/:/root/.nomadnetwork/ \
-v /local/path/reticulumconfigdir/:/root/.reticulum/ \
--network host \
ghcr.io/markqvist/nomadnet:master

# Run isolated from host network
podman run -d \
-v /local/path/nomadnetconfigdir/:/root/.nomadnetwork/ \
-v /local/path/reticulumconfigdir/:/root/.reticulum/ \
ghcr.io/markqvist/nomadnet:master

# Run with console logging
podman run -i ghcr.io/markqvist/nomadnet:master --daemon --console
```

## NomadNet Podman Kata-Containers

Kata-containers are hardware virtualized containers but lighter than full VMs.

```bash
podman --runtime /usr/bin/kata-runtime run -d --name nomadnet --network host ghcr.io/markqvist/nomadnet:master
```


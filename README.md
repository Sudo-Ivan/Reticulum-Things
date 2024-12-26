# Reticulum Things

Everything reticulum. 

## NomadNet Podman

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

## Ivans Reticulum Bots
[See on Gitlab](https://gitlab.com/ivans-reticulum-bots)

### Weather Bot

Gets weather from OpenWeatherMap.

### Trivia Bot

### LXMF Bot Framework

General purpose bot framework.

### JS8Call-Bot

JS8Call bridge bot.

### Group Message Distribution Bot

Distributes messages to a group of users.

## Ivans Reticulum Bridges

Discord, Matrix, Telegram, etc.

Repo coming soon.

### Discord Bridge

A bridge between discord and reticulum. 

Features:

- Basic Message Support
- Image Attachment Support




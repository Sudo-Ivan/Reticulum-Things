#!/bin/bash

# Exit on any error
set -e

echo "Installing Kata Containers and dependencies..."

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
fi

# Install required packages using yay
echo "Installing required packages..."
yay -S --needed \
    podman \
    qemu-full \
    kata-runtime-bin \
    linux-kata-bin \
    kata-containers-image-bin

# Load required kernel modules
echo "Loading required kernel modules..."
sudo modprobe kvm
sudo modprobe kvm_intel  # or kvm_amd depending on your CPU
sudo modprobe vhost
sudo modprobe vhost_net
sudo modprobe vhost_vsock

# Add modules to load at boot
echo "Configuring modules to load at boot..."
cat << EOF | sudo tee /etc/modules-load.d/kata-containers.conf
kvm
kvm_amd
vhost
vhost_net
vhost_vsock
EOF

# Create required directories
sudo mkdir -p /etc/kata-containers
sudo mkdir -p /etc/containers

# Copy default Kata configuration if it doesn't exist
if [ ! -f /etc/kata-containers/configuration.toml ]; then
    sudo cp /usr/share/defaults/kata-containers/configuration-qemu.toml /etc/kata-containers/configuration.toml
fi

# Create vmlinux.container symlink if it doesn't exist
if [ ! -f /usr/share/kata-containers/vmlinux.container ]; then
    LATEST_KERNEL=$(ls -1 /usr/share/kata-containers/vmlinux-* | sort -V | tail -n 1)
    if [ -n "$LATEST_KERNEL" ]; then
        sudo ln -sf "$LATEST_KERNEL" /usr/share/kata-containers/vmlinux.container
        echo "Created kernel symlink: $LATEST_KERNEL -> vmlinux.container"
    else
        echo "Warning: No vmlinux kernel found!"
    fi
fi

# Configure Podman to use Kata
cat << EOF | sudo tee /etc/containers/containers.conf
[engine]
runtime = [
    "/usr/bin/kata-runtime=/usr/bin/kata-runtime"
]

[engine.runtimes]
kata = [
    "/usr/bin/kata-runtime"
]
EOF

# Check if virtualization is enabled in BIOS
if ! grep -q "^flags.*\bsvm\b" /proc/cpuinfo && ! grep -q "^flags.*\bvmx\b" /proc/cpuinfo; then
    echo "ERROR: CPU virtualization is not enabled in BIOS"
    echo "Please enable SVM (AMD) or VT-x (Intel) in your BIOS settings"
    exit 1
fi

echo "Verifying installation..."

# Verify kata-runtime
if kata-runtime check; then
    echo "Kata runtime check passed"
else
    echo "Warning: Kata runtime check failed"
fi

# Test Podman with Kata
echo "Testing Podman with Kata runtime..."
if podman --runtime kata run --rm hello-world; then
    echo "Podman + Kata test successful"
else
    echo "Warning: Podman + Kata test failed"
fi

echo "Installation complete!"
echo "You can now run containers with Kata using:"
echo "podman --runtime kata run ..." 
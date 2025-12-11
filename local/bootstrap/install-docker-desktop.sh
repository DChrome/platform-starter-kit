#!/bin/bash

INSTALL_DIR="/Applications"
DMG_NAME="Docker.dmg"
DMG_PATH="/tmp/$DMG_NAME"
VOLUME_NAME="Docker"
APP_NAME="Docker.app"

echo "Starting Docker Desktop installation script..."

# Determine Architecture and Download URL
ARCH=$(uname -m)
if [[ "$ARCH" = "arm64" ]]; then
    echo "Detected Apple Silicon (arm64) architecture."
    # Official URL for Apple Silicon
    DOWNLOAD_URL="https://desktop.docker.com/mac/stable/arm64/Docker.dmg"
elif [[ "$ARCH" = "x86_64" ]]; then
    echo "Detected Intel (x86_64) architecture."
    # Official URL for Intel
    DOWNLOAD_URL="https://desktop.docker.com/mac/stable/amd64/Docker.dmg"
else
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
fi

# Check if Docker Desktop is already installed
if [[ -d "$INSTALL_DIR/$APP_NAME" ]]; then
    echo "[OK] Docker Desktop already installed at $INSTALL_DIR/$APP_NAME. Skipping."
    exit 0
fi

# Download the DMG File
echo "Downloading Docker Desktop from $DOWNLOAD_URL to $DMG_PATH..."
if curl -L "$DOWNLOAD_URL" -o "$DMG_PATH"; then
    echo "[OK] Download complete."
else
    echo "[ERROR] Download failed. Exiting."
    exit 1
fi

# Mount the Disk Image
echo "Mounting the disk image..."
if ! hdiutil attach "$DMG_PATH" -quiet -noverify -mountpoint "/Volumes/$VOLUME_NAME"; then
    echo "[ERROR] Failed to mount disk image. Exiting."
    # Proceed to clean up in case of failure
    rm -f "$DMG_PATH"
    exit 1
fi

# Perform the Installation
echo "Installing Docker Desktop to $INSTALL_DIR..."
# The --accept-license flag performs a silent, non-interactive installation.
# The --user flag avoids privileged configuration prompts on the first launch.
sudo "/Volumes/$VOLUME_NAME/$APP_NAME/Contents/MacOS/install" --accept-license --user="$(whoami)"

# Check if installation was successful
if [[ -d "$INSTALL_DIR/$APP_NAME" ]]; then
    echo "[OK] Installation successful."
else
    echo "[ERROR] Installation failed or application not found in $INSTALL_DIR. Exiting."
    # Proceed to unmount and clean up
    hdiutil detach "/Volumes/$VOLUME_NAME" -quiet
    rm -f "$DMG_PATH"
    exit 1
fi

echo "Starting Docker Desktop."
open -j "$INSTALL_DIR/$APP_NAME"

# Clean Up
echo "Cleaning up: Unmounting disk image and deleting the DMG file..."
# Unmount the volume
hdiutil detach "/Volumes/$VOLUME_NAME" -quiet
# Delete the downloaded file
rm -f "$DMG_PATH"

echo "[OK] Installation script finished successfully."
exit 0
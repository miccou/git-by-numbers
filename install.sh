#!/bin/bash

# Install gbn to ~/bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/bin
cp "$SCRIPT_DIR/gbn" ~/bin/gbn
chmod +x ~/bin/gbn

echo "Installed gbn to ~/bin/gbn"

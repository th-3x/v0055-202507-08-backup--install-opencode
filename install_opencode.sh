#!/bin/bash

set -e

# Function to display usage
usage() {
  echo "Usage: $0 --key <GEMINI_API_KEY>"
  echo "  --key: Your Google Gemini API key."
  exit 1
}

# Parse command-line arguments
GEMINI_API_KEY=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --key)
      GEMINI_API_KEY="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# Check if API key is provided
if [ -z "$GEMINI_API_KEY" ]; then
  echo "Error: Gemini API key is required."
  usage
fi

echo "Starting OpenCode installation..."

# 1. Install Go
echo "Installing Go..."
sudo rm -rf /usr/local/go
wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
rm go1.24.0.linux-amd64.tar.gz

# Set Go PATH for current session and add to .profile
export PATH=/usr/local/go/bin:$PATH
if ! grep -q "export PATH=\"/usr/local/go/bin:\$PATH\"" ~/.profile; then
  echo "export PATH=\"/usr/local/go/bin:\$PATH\"" >> ~/.profile
fi
source ~/.profile

echo "Go installed: $(go version)"

# 2. Install OpenCode
echo "Installing OpenCode..."
go install github.com/opencode-ai/opencode@latest

# Set GOPATH/bin to PATH for current session and add to .profile
export PATH=$PATH:$(go env GOPATH)/bin
if ! grep -q "export PATH=\\$PATH:\\$(go env GOPATH)\\/bin" ~/.profile; then
  echo "export PATH=\\$PATH:\\$(go env GOPATH)\\/bin" >> ~/.profile
fi
source ~/.profile

echo "OpenCode installed: $(opencode --version)"

# 3. Configure OpenCode for Gemini Flash model
echo "Configuring OpenCode for gemini-2.5-flash model..."
cat << EOF_JSON > ~/.opencode.json
{
  "agents": {
    "coder": {
      "model": "gemini-2.5-flash",
      "maxTokens": 5000
    },
    "task": {
      "model": "gemini-2.5-flash",
      "maxTokens": 5000
    },
    "title": {
      "model": "gemini-2.5-flash",
      "maxTokens": 80
    }
  }
}
EOF_JSON

# 4. Set Gemini API Key environment variable
echo "Setting GEMINI_API_KEY..."
if ! grep -q "export GEMINI_API_KEY=\"$GEMINI_API_KEY\"" ~/.profile; then
  echo "export GEMINI_API_KEY=\"$GEMINI_API_KEY\"" >> ~/.profile
else
  sed -i "s/^export GEMINI_API_KEY=.*$/export GEMINI_API_KEY=\"$GEMINI_API_KEY\"/" ~/.profile
fi
source ~/.profile

echo "OpenCode installation and configuration complete!"
echo "You can now run opencode with: opencode -p \"Your prompt here\""




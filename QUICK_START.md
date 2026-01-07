# Quick Start Guide

Get Pownin Assistant running in under 5 minutes.

## Swift macOS App (Universal Binary)

```bash
# Clone and build
git clone https://github.com/sumitduster-iMac/Pownin-Assistant.git
cd Pownin-Assistant

# Build Universal binary (Intel + Apple Silicon)
make build-universal

# Or build for your specific architecture
make build-intel    # Intel Mac
make build-arm      # Apple Silicon Mac

# Run the application
swift run
```

## Electron Cross-Platform App

```bash
cd electron-app
npm install
npm start

# Package for distribution
npm run package:mac-universal  # macOS Universal
npm run package:win            # Windows
npm run package:linux          # Linux
```

## AI Configuration (Optional)

Set any of these environment variables:

```bash
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="..."
export MISTRAL_API_KEY="..."
```

Works without API keys using local AI fallback.

## Verify Build

```bash
# Check architectures in Universal binary
make check-arch

# Verify AI integration
make verify-ai
```

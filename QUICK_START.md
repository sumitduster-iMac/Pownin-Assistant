# Quick Start Guide

Get Pownin Assistant running in under 5 minutes.

## Swift macOS App

```bash
# Clone and build
git clone https://github.com/sumitduster-iMac/Pownin-Assistant.git
cd Pownin-Assistant
swift build -c release --arch x86_64
swift run
```

## Electron Cross-Platform App

```bash
cd electron-app
npm install
npm start
```

## AI Configuration (Optional)

Set any of these environment variables:

```bash
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

Works without API keys using local AI fallback.

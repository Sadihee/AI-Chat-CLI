# AI-Chat CLI

A **Bash-based AI chat terminal** for interacting with local or remote Large Language Models (LLMs). Designed for developers and power users, it supports conversation context persistence, multi-model selection, and customizable configurations.

---

## Features

✅ **Local LLM Integration**: Connects to locally hosted LLM servers (e.g., `http://xxx.xxx.xxx.xxx:1234/v1`).
✅ **Conversation Context**: Automatically saves and loads chat history to maintain context.
✅ **Multi-Model Support**: Dynamically fetches available models and allows switching between them.
✅ **Interactive Mode**: Supports continuous conversation until the user exits.
✅ **Customizable**: Configure API keys, models, and server URLs via environment variables or config files.
✅ **Pretty Output**: Uses `glow` for syntax-highlighted messages with colored timestamps.

---

## Requirements

- **Bash**: Version 4.0 or higher.
- **curl**: For HTTP requests.
- **jq**: For JSON processing.
- **glow** (optional): For enhanced terminal output.

Install dependencies (Ubuntu/Debian example):
```bash
sudo apt update
sudo apt install -y curl jq glow
```

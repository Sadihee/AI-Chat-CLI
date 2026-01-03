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
- **glow**: For enhanced terminal output.

Install dependencies (Ubuntu/Debian example):
```bash
sudo apt update
sudo apt install -y curl jq glow
```

Installation
1. Clone the Repository
```bash
git clone https://github.com/Sadihee/AI-Chat-CLI.git
cd ai-chat-cli
```


2. Configure Environment Variables
write your configurations into chat.sh
```bash
API_KEY="your_api_key_here"                # Replace with your API key
BASE_URL="http://xxx.xxx.xxx.xxx:1234/v1"  # Replace with your LLM server URL
MODEL_ID="openai/gpt-oss-20b"              # Default model ID
CONV_FILE="\${HOME}/.ai_chat_log"          # Path to conversation log file
```

Then run:

```bash
bash chat.sh "Hello, can you help optimize this code? ..."
```



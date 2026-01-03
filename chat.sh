#!/usr/bin/bash
# ------------------------------------------------------------------
# AI‑Chat CLI – Bash rewrite of the original script.
# ------------------------------------------------------------------

# ────────────────────────────────────────────────────────────────
# Configuration section – keep these values in a separate file or
# environment variables if you plan to reuse the script.
# ────────────────────────────────────────────────────────────────

BASE_URL="http://xxx.xxx.xxx.xxx:1234/v1"                       # Endpoint of the local LLM server
MODEL_ID="openai/gpt-oss-20b"                                   # Model identifier used by the API
API_KEY="sk-apikey"                                             # Bearer token for authentication
CONV_FILE="${HOME}/.tmp"                                        # File path for the conversation log

# ────────────────────────────────────────────────────────────────
# Helper: persistent conversation storage.
#
# The original Bash script used a hidden file `~/.tmp` to keep the
# conversation history as a JSON array.  We preserve that behaviour,
# but add safety checks and comments.
# ────────────────────────────────────────────────────────────────

load_conversation() {
    # If the file does not exist, start with an empty JSON array
    if [[ ! -f "${CONV_FILE}" ]]; then
        echo '[]' > "${CONV_FILE}"
    fi
    # Output the current contents (a JSON array) to stdout
    cat "${CONV_FILE}"
}

save_conversation() {
    # First argument: the updated JSON array as a string
    local new_content="${1}"
    # Write it back atomically – replace the old file with a temporary one
    echo "${new_content}" > "${CONV_FILE}.tmp"
    mv "${CONV_FILE}.tmp" "${CONV_FILE}"
}

# ────────────────────────────────────────────────────────────────
# Helper: display a coloured timestamped header.
#
# We mimic the original Bash output style using ANSI escape codes.
# ────────────────────────────────────────────────────────────────

print_user_info(){
    echo -e "\033[91;3;7m$(date +'%H:%M:%S') 👤 $(whoami)@$(hostname) \033[0m"
    echo "$*" | glow
}


print_ai_info(){
    echo -e "\033[96;3;7m$(date +'%H:%M:%S') 🤖 $MODEL_ID@$BASE_URL \033[0m"
    echo "$*" | glow
}


# ────────────────────────────────────────────────────────────────
# Core functionality: retrieve the list of available models.
#
# This function wraps a simple curl request and parses the output
# with jq to extract model IDs.  It returns them as a newline‑separated
# list on stdout.
# ────────────────────────────────────────────────────────────────

fetch_model_list() {
    local url="${BASE_URL}/models"
    # Perform an authenticated GET; silence progress bar with -s
    local rsp="$(curl -s "${url}" \
        -H "Authorization: Bearer ${API_KEY}")"

    # Extract each model ID from the JSON array and print it
    echo "${rsp}" | jq -r '.data[].id'
}

# ────────────────────────────────────────────────────────────────
# Core functionality: chat with the LLM.
#
# This function mirrors the original `get_llm_chat` Bash block:
#   * Load or create the conversation history
#   * Append the user’s message
#   * Build a request payload
#   * Call the /chat/completions endpoint
#   * Display the assistant response
#   * Persist the updated conversation back to disk
# ────────────────────────────────────────────────────────────────

chat_with_llm() {
    # --------------------------------------------------------------
    # Load existing history or start fresh if the file is missing.
    # --------------------------------------------------------------
    local messages="$(load_conversation)"          # JSON array string

    print_user_info "$*"
    # --------------------------------------------------------------
    # Append the new user message to the conversation list.
    # --------------------------------------------------------------
    # jq will add a new object {"role":"user","content":"…"} to the array
    messages="$(echo "${messages}" | \
        jq --arg role "user" --arg content "$*" '. += [{"role": $role, "content": $content}]')"

    # --------------------------------------------------------------
    # Prepare the request payload as per OpenAI API spec.
    # --------------------------------------------------------------
    local prompt="$(echo "${messages}" | jq -c '.')"

    # --------------------------------------------------------------
    # Build the JSON body for curl.  Use single quotes to avoid
    # shell interpolation, but escape inner double‑quotes with \".
    # --------------------------------------------------------------
    local info="{\"model\": \"${MODEL_ID}\",\"messages\": ${prompt}}"

    # --------------------------------------------------------------
    # Make the HTTP POST to /chat/completions with proper headers.
    # --------------------------------------------------------------
    local url="${BASE_URL}/chat/completions"
    local rsp="$(curl -s "${url}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "${info}")"

    # --------------------------------------------------------------
    # Extract the assistant's reply from the JSON response.
    # --------------------------------------------------------------
    local reply_text="$(echo "${rsp}" | jq -r '.choices[0].message.content')"

    # --------------------------------------------------------------
    # Display user and assistant messages with coloured headers,
    # mimicking the original Bash script’s output formatting.
    # --------------------------------------------------------------
    # print_header "$(whoami)@$(hostname)" "$*"
    # print_user_info "$*"
    # print_header "${MODEL_ID}@${BASE_URL}" "${reply_text}"
    print_ai_info   "$reply_text"

    # --------------------------------------------------------------
    # Append the assistant's reply to the conversation list for future context.
    # --------------------------------------------------------------
    messages="$(echo "${messages}" | \
        jq --arg role "assistant" --arg content "${reply_text}" '. += [{"role": $role, "content": $content}]')"

    # --------------------------------------------------------------
    # Persist the updated conversation back to disk for next round.
    # --------------------------------------------------------------
    save_conversation "${messages}"
}

# ────────────────────────────────────────────────────────────────
# Main entry point – parse command‑line arguments and dispatch.
#
# The Bash script invoked `get_llm_chat "$*"`, i.e. forwarded all
# positional parameters as a single message string.  We emulate that
# behaviour here: join all `$@` into one space‑separated sentence.
# ────────────────────────────────────────────────────────────────

main() {
    # --------------------------------------------------------------
    # If the user supplied no arguments, print usage instructions.
    # --------------------------------------------------------------
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <message>"
        exit 1
    fi

    # --------------------------------------------------------------
    # Concatenate all positional arguments into a single message.
    # --------------------------------------------------------------
    local raw_message="$*"

    # --------------------------------------------------------------
    # Execute the chat flow with the provided user input.
    # --------------------------------------------------------------
    chat_with_llm "${raw_message}"
}

# Invoke the main function with all script arguments
main "$@"

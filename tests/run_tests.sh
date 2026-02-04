#!/usr/bin/env bash

# Shell Pilot Test Suite

# Load environment variables from .env if it exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

# Setup environment
# Setup environment
TEST_BIN_DIR="$SCRIPT_DIR/test_bin"
export SHELL_PILOT_CONFIG_PATH="$TEST_BIN_DIR"
export SHELL_PILOT_PLUGINS_PATH="$TEST_BIN_DIR/plugins"
export COMMON_CONFIG_FILE="$TEST_BIN_DIR/spilot_common.sh"
mkdir -p "$SHELL_PILOT_PLUGINS_PATH"
mkdir -p ~/spilot_files_dir

# Mock common config logic for testing
# We need the real escape function from spilot_common.sh
source ./spilot_common.sh
source ./spilot_llm_rq_apis.sh

test_count=0
success_count=0

assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    test_count=$((test_count + 1))
    if [ "$expected" == "$actual" ]; then
        echo -e "\033[32m[PASS]\033[0m $message"
        success_count=$((success_count + 1))
    else
        echo -e "\033[31m[FAIL]\033[0m $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
    fi
}

echo "Running Shell Pilot Tests..."

# 1. Test escape function
escaped=$(escape 'Hello "World"
New Line')
assert_eq 'Hello \"World\"\nNew Line' "$escaped" "Characters should be escaped for JSON"

# 2. Test Groq Model compound logic
curl() {
    # Print all args to verify structure
    echo "$@"
}
export -f curl

test_groq_compound_injection() {
    USE_API="groq"
    MODEL_GROQ="groq/compound"
    GROQ_API_KEY="test_key"
    SYSTEM_PROMPT="sys"
    MAX_TOKENS=100
    TEMPERATURE=1
    
    output=$(request_to_chat '{"role": "user", "content": "hi"}')
    if [[ "$output" == *"compound_custom"* ]]; then
        assert_eq "1" "1" "Groq compound model should inject tools"
    else
        assert_eq "1" "0" "Groq compound model should inject tools"
    fi
}

test_groq_compound_injection

# 3. Test non-compound Groq model (should NOT have compound_custom)
test_groq_normal_model() {
    USE_API="groq"
    MODEL_GROQ="openai/gpt-oss-120b"
    GROQ_API_KEY="test_key"
    
    output=$(request_to_chat '{"role": "user", "content": "hi"}')
    if [[ "$output" == *"compound_custom"* ]]; then
        assert_eq "0" "1" "Normal Groq model should NOT inject tools"
    else
        assert_eq "0" "0" "Normal Groq model should NOT inject tools"
    fi
}

test_groq_normal_model

# 4. Integration Test: Real API call to Groq compound-mini
# This test requires a valid GROQ_API_KEY environment variable
test_groq_compound_mini_integration() {
    # Unset the mock curl to use the real one
    unset -f curl
    
    # Re-source .env to ensure GROQ_API_KEY is set
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        source <(grep GROQ_API_KEY "$PROJECT_ROOT/.env")
    fi
    
    # Check if GROQ_API_KEY is set
    if [[ -z "$GROQ_API_KEY" ]]; then
        echo -e "\033[33m[SKIP]\033[0m Groq compound-mini API call (GROQ_API_KEY not set)"
        return 0
    fi
    
    SYSTEM_PROMPT="You are a helpful assistant."
    MAX_TOKENS=100
    TEMPERATURE=0.7
    
    # Make a real API call directly using curl binary
    escaped_system_prompt=$(escape "$SYSTEM_PROMPT")
    response=$(/usr/bin/curl https://api.groq.com/openai/v1/chat/completions \
        -sS \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -d '{
            "model": "groq/compound-mini",
            "messages": [
                {"role": "system", "content": "'"$escaped_system_prompt"'"},
                {"role": "user", "content": "What command lists a folder content in Ubuntu terminal?"}
            ],
            "max_tokens": '$MAX_TOKENS',
            "temperature": '$TEMPERATURE'
        }')
    
    # Check if we got a valid response (contains 'choices' or 'content')
    if [[ "$response" == *"choices"* ]] || [[ "$response" == *"content"* ]]; then
        # Extract the actual message content
        message=$(echo "$response" | jq -r '.choices[0].message.content // .content // empty' 2>/dev/null)
        if [[ -n "$message" && "$message" != "null" ]]; then
            echo "  Groq Response: $message"
            assert_eq "1" "1" "Groq compound-mini API call returns valid response"
        else
            echo "  Raw response: $response"
            assert_eq "1" "0" "Groq compound-mini API call returns valid response"
        fi
    else
        echo "  Error response: $response"
        assert_eq "1" "0" "Groq compound-mini API call returns valid response"
    fi
}

test_groq_compound_mini_integration

# 5. CLI Feature Tests
# Setup test environment with local config files
setup_cli_tests() {
    cp "$PROJECT_ROOT/s-pilot" "$SHELL_PILOT_CONFIG_PATH/s-pilot"
    cp "$PROJECT_ROOT/spilot_common.sh" "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"
    cp "$PROJECT_ROOT/spilot_llm_rq_apis.sh" "$SHELL_PILOT_CONFIG_PATH/spilot_llm_rq_apis.sh"
    # Copy plugins recursively (using . to avoid nested plugins folder)
    cp -r "$PROJECT_ROOT/plugins/." "$SHELL_PILOT_PLUGINS_PATH/"
    
    chmod +x "$SHELL_PILOT_CONFIG_PATH/s-pilot"
    chmod +w "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"
}

setup_cli_tests

# Test Wrapper
run_spilot() {
    bash "$SHELL_PILOT_CONFIG_PATH/s-pilot" "$@"
}

# 5.1 Test Version
test_version() {
    output=$(run_spilot -v)
    if [[ "$output" == *"[Shell Pilot Version]"* ]]; then
        assert_eq "1" "1" "CLI: -v (version) works"
    else
        assert_eq "1" "0" "CLI: -v (version) failed"
        echo "    Output: $output"
    fi
}
test_version

# 5.2 Test Help
test_help() {
    output=$(run_spilot -h)
    if [[ "$output" == *"Commands:"* && "$output" == *"Options:"* ]]; then
        assert_eq "1" "1" "CLI: -h (help) works"
    else
        assert_eq "1" "0" "CLI: -h (help) failed"
        echo "    Output: $output"
    fi
}
test_help

# 5.3 Test List Config
test_list_config() {
    output=$(run_spilot -lc)
    if [[ "$output" == *"USE_API"* ]]; then
        assert_eq "1" "1" "CLI: -lc (list config) works"
    else
        assert_eq "1" "0" "CLI: -lc (list config) failed"
        echo "    Output: $output"
    fi
}
test_list_config

# 5.4 Test Change Provider
test_change_provider() {
    # Ensure clean state
    output=$(run_spilot -cmp groq)
    # Check if config file was updated (handle quoted or unquoted values)
    if grep -q 'USE_API=.*groq' "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"; then
        assert_eq "1" "1" "CLI: -cmp (change provider) updates config correctly"
    else
        assert_eq "1" "0" "CLI: -cmp failed to update config"
        echo "    Output: $output"
    fi
}
test_change_provider

# 5.5 Test Change Model
test_change_model() {
    # Update model for groq
    output=$(run_spilot -m "groq/compound-mini")
    
    if grep -q 'MODEL_GROQ=.*groq/compound-mini' "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"; then
        assert_eq "1" "1" "CLI: -m (model) updates config correctly"
    else
        assert_eq "1" "0" "CLI: -m failed to update config"
        echo "    Output: $output"
    fi
}
test_change_model

# 5.6 Test Temperature
test_temperature() {
    output=$(run_spilot -t 0.5)
    if grep -q 'TEMPERATURE=.*0.5' "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"; then
        assert_eq "1" "1" "CLI: -t (temperature) updates config correctly"
    else
        assert_eq "1" "0" "CLI: -t failed to update config"
        echo "    Output: $output"
    fi
}
test_temperature

# 5.7 Test Max Tokens
test_max_tokens() {
    output=$(run_spilot -mt 2048)
    if grep -q 'MAX_TOKENS=.*2048' "$SHELL_PILOT_CONFIG_PATH/spilot_common.sh"; then
        assert_eq "1" "1" "CLI: -mt (max tokens) updates config correctly"
    else
        assert_eq "1" "0" "CLI: -mt failed to update config"
        echo "    Output: $output"
    fi
}
test_max_tokens

# Cleanup
rm -rf "$TEST_BIN_DIR"

echo -e "\nSummary: $success_count/$test_count tests passed."

if [ $success_count -ne $test_count ]; then
    exit 1
fi

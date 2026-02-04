#!/usr/bin/env bash

# Shell Pilot Test Suite

# Setup environment
export SHELL_PILOT_CONFIG_PATH="./test_bin"
export SHELL_PILOT_PLUGINS_PATH="./test_bin/plugins"
export COMMON_CONFIG_FILE="./test_bin/spilot_common.sh"
mkdir -p ./test_bin/plugins
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
    
    # Check if GROQ_API_KEY is set
    if [[ -z "$GROQ_API_KEY" ]]; then
        echo -e "\033[33m[SKIP]\033[0m Groq compound-mini API call (GROQ_API_KEY not set)"
        return 0
    fi
    
    USE_API="groq"
    MODEL_GROQ="groq/compound-mini"
    SYSTEM_PROMPT="You are a helpful assistant."
    MAX_TOKENS=100
    TEMPERATURE=0.7
    
    # Make a real API call
    response=$(request_to_chat '{"role": "user", "content": "Say hello in one word."}')
    
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

# Cleanup
rm -rf ./test_bin

echo -e "\nSummary: $success_count/$test_count tests passed."

if [ $success_count -ne $test_count ]; then
    exit 1
fi

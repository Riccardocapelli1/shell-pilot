#!/usr/bin/env bash

# Test script for s-pilot command execution workflow
# This script simulates the execution of 3 commands via the 'cmd:' prefix.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_BIN_DIR="$SCRIPT_DIR/test_execution_bin"

# Setup test environment
export SHELL_PILOT_CONFIG_PATH="$TEST_BIN_DIR"
export SHELL_PILOT_PLUGINS_PATH="$TEST_BIN_DIR/plugins"
export COMMON_CONFIG_FILE="$TEST_BIN_DIR/spilot_common.sh"
mkdir -p "$SHELL_PILOT_PLUGINS_PATH"
mkdir -p "$TEST_BIN_DIR/files"
export SPILOT_FILES_DEFAULT_DIR="$TEST_BIN_DIR/files"

# Copy project files
cp "$PROJECT_ROOT/s-pilot" "$TEST_BIN_DIR/s-pilot"
cp "$PROJECT_ROOT/spilot_common.sh" "$TEST_BIN_DIR/spilot_common.sh"
cp "$PROJECT_ROOT/spilot_llm_rq_apis.sh" "$TEST_BIN_DIR/spilot_llm_rq_apis.sh"
cp -r "$PROJECT_ROOT/plugins/." "$SHELL_PILOT_PLUGINS_PATH/"
chmod +x "$TEST_BIN_DIR/s-pilot"

# Fix tput issue in non-interactive shell
sed -i 's/COLUMNS=$(tput cols)/COLUMNS=80/g' "$TEST_BIN_DIR/spilot_common.sh"

# Patch the template s-pilot to disable automatic stdin consumption and spinner
sed -i 's/pipe_mode_prompt+=$(cat -)/pipe_mode_prompt=""/g' "$TEST_BIN_DIR/s-pilot"
sed -i '/while IFS= read -r line; do/,/done/d' "$TEST_BIN_DIR/s-pilot"
sed -i 's/read -e/read/g' "$TEST_BIN_DIR/s-pilot"
sed -i 's/read prompt/read prompt || prompt="quit"/g' "$TEST_BIN_DIR/s-pilot"
sed -i 's/dynamic_spinner_wait &/true/g' "$TEST_BIN_DIR/s-pilot"
sed -i 's/wait $dynamic_spinner_pid/true/g' "$TEST_BIN_DIR/s-pilot"
sed -i 's/read run_answer/run_answer="Yes"; echo "DEBUG: run_answer forced to [Yes]" >\&2/g' "$TEST_BIN_DIR/s-pilot"

# Mock curl to simulate Groq API response
cat << 'EOF' > "$TEST_BIN_DIR/curl"
#!/usr/bin/env bash
# Arguments are in "$@"
ARGS="$*"

if [[ "$ARGS" == *"models"* ]]; then
    echo "{\"data\": [{\"id\": \"groq/compound-mini\"}]}"
    exit 0
fi

if [[ "$ARGS" == *"directory content"* ]]; then
    CMD="ls -F"
elif [[ "$ARGS" == *"spazio disco"* ]]; then
    CMD="df -h"
elif [[ "$ARGS" == *"system uptime"* ]]; then
    CMD="uptime"
else
    CMD="ls -l"
fi

echo "{\"choices\": [{\"message\": {\"content\": \"$CMD\"}}]}"
EOF
chmod +x "$TEST_BIN_DIR/curl"

# Override PATH to use our mock curl
export PATH="$TEST_BIN_DIR:$PATH"

# Create a mock curl binary at an absolute path
MOCK_CURL="/tmp/shell_pilot_mock_curl"
cat << 'EOF' > "$MOCK_CURL"
#!/usr/bin/env bash
ARGS="$*"
CMD="ls -F"
if [[ "$ARGS" == *"models"* ]]; then
    echo '{"data": [{"id": "groq/compound-mini"}]}'
    exit 0
fi
if [[ "$ARGS" == *"directory content"* ]]; then CMD="ls -F"; fi
if [[ "$ARGS" == *"spazio disco"* ]]; then CMD="df -h"; fi
if [[ "$ARGS" == *"system uptime"* ]]; then CMD="uptime"; fi
echo "{\"choices\": [{\"message\": {\"content\": \"$CMD\"}}]}"
EOF
chmod +x "$MOCK_CURL"

# Patch spilot_llm_rq_apis.sh to use the mock curl
sed -i "s|curl |$MOCK_CURL |g" "$TEST_BIN_DIR/spilot_llm_rq_apis.sh"

# Function to run a test case
run_test_case() {
    local description="$1"
    local prompt="$2"
    local expected_output_pattern="$3"
    
    echo "------------------------------------------------"
    echo "TEST: $description"
    echo "Request: $prompt"
    
    # Run s-pilot
    # Sequence: 1. Command, 2. quit (Yes is hardcoded)
    output=$(timeout 10s bash -c "echo -e '${prompt}\nquit' | bash '$TEST_BIN_DIR/s-pilot' 2>&1")
    
    echo "s-pilot output:"
    echo "$output"
    
    if [[ "$output" == *"$expected_output_pattern"* ]]; then
        echo -e "\n\033[32m[PASS]\033[0m Workflow completed and output matched pattern."
    else
        echo -e "\n\033[31m[FAIL]\033[0m Output did not match expected pattern: $expected_output_pattern"
    fi
}

# 1. Test 'ls'
run_test_case "List directory content" "cmd: how to list the current directory content?" "run_tests.sh"

# 2. Test 'df -h'
# Since the system is in Italian, 'Filesystem' becomes 'File system' or 'Usati'
run_test_case "Disk free space" "cmd: mostra lo spazio disco libero in modo leggibile" "Usati"

# 3. Test 'uptime'
run_test_case "System uptime" "cmd: check system uptime" "up"

# Cleanup
# rm -rf "$TEST_BIN_DIR"
# rm "$MOCK_CURL"
echo "------------------------------------------------"
echo "Test execution completed."

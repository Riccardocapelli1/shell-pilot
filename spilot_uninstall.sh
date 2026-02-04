#!/usr/bin/env bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31mThis script must be run as root to remove files from /usr/local/bin.\033[0m"
  exit 1
fi

INSTALL_PATH="/usr/local/bin"
PLUGINS_PATH="/usr/local/bin/plugins"

echo "==> Uninstalling Shell Pilot..."

# Remove binaries and scripts
files_to_remove=(
    "${INSTALL_PATH}/s-pilot"
    "${INSTALL_PATH}/spilot_common.sh"
    "${INSTALL_PATH}/spilot_llm_rq_apis.sh"
    "${PLUGINS_PATH}/package_version.sh"
    "${PLUGINS_PATH}/system_alias.sh"
)

for file in "${files_to_remove[@]}"; do
    if [ -f "$file" ]; then
        rm -v "$file"
    fi
done

# Remove plugins directory if empty
if [ -d "$PLUGINS_PATH" ] && [ -z "$(ls -A "$PLUGINS_PATH")" ]; then
    rmdir -v "$PLUGINS_PATH"
fi

# Remove user data directory option
read -p "==> Would you like to remove user data and history (~/spilot_files_dir)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rfv ~/spilot_files_dir
fi

echo -e "\n==> Shell Pilot has been uninstalled."
echo "Note: API keys in your shell profile (~/.bash_profile, ~/.zshrc, etc.) were NOT removed. Please remove them manually if desired."

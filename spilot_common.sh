# This is config file for spilot
GLOBIGNORE="*"
# output formatting
SHELLPILOT_CYAN_LABEL="\033[94ms-pilot: \033[0m"
PROCESSING_LABEL="\n\033[92m  Processing... \033[0m\033[0K\r"
OVERWRITE_PROCESSING_LINE="             \033[0K\r"
COLUMNS=$(tput cols)

# version: major.minor.patch
SHELL_PILOT_VERSION=1.14.7

# store directory
SPILOT_FILES_DEFAULT_DIR=~/spilot_files_dir

# the list models cache setting
CACHE_MAX_AGE=3600
LIST_MODELS_CACHE_FILE="$SPILOT_FILES_DEFAULT_DIR/models_list.cache"

# Configuration settings: groq, nvidia
USE_API=groq
CURRENT_DATE=$(date +%m/%d/%Y)

if [ "$USE_API" == "groq" ]; then
    MODEL_NAME="Groq"
    ORGANIZATION="Groq"
    GROQ_SYSTEM_PROMPT="Agisci come esperto sistemista Debian. Traduci richieste in linguaggio naturale in comandi Bash precisi. Segui questi vincoli: usa sintassi Debian Stable e apt per i pacchetti; usa sudo solo se necessario. Se un comando è distruttivo, inserisci un commento di avvertimento. Fornisci il codice in blocchi Markdown, includendo commenti esplicativi brevi. Preferisci i 'one-liner' per operazioni semplici, ma usa script strutturati con shebang #!/bin/bash e set -e per logiche complesse. Gestisci i percorsi con virgolette per evitare errori con gli spazi. Sii sintetico: restituisci solo il codice funzionante, salvo diversa richiesta dell'utente."
fi

if [ "$USE_API" == "nvidia" ]; then
    MODEL_NAME="NVIDIA"
    ORGANIZATION="NVIDIA"
fi

# Define prompts using the adjusted settings
CHAT_INIT_PROMPT="You are $MODEL_NAME, a Large Language Model trained by $ORGANIZATION. You will be answering questions from users. Answer as concisely as possible for each response. Keep the number of items short. Output your answer directly, with no labels in front. Today's date is $CURRENT_DATE."
SYSTEM_PROMPT="You are $MODEL_NAME, a large language model trained by $ORGANIZATION. Answer as concisely as possible. Current date: $CURRENT_DATE."
[[ "$USE_API" == "groq" ]] && SYSTEM_PROMPT="$GROQ_SYSTEM_PROMPT $SYSTEM_PROMPT"
COMMAND_GENERATION_PROMPT="You are a Debian Linux expert. Your task is to provide functioning Bash commands for Debian Stable. Return a CLI command and nothing else - do not send it in a code block, quotes, or anything else, just the pure text CONTAINING ONLY THE COMMAND. If possible, return a one-line bash command or chain many commands together. Return ONLY the command ready to run in the terminal. The command should do the following:"

# chat settings
TEMPERATURE=0.9
MAX_TOKENS=4096
STREAM=false
MODEL_GROQ=openai/gpt-oss-120b
MODEL_NVIDIA=mistralai/devstral-2-123b-instruct-2512
CONTEXT=false
MULTI_LINE_PROMPT=false
ENABLE_DANGER_FLAG=false
DANGEROUS_COMMANDS=("rm" ">" "mv" "mkfs" ":(){:|:&};" "dd" "chmod" "wget" "curl")

escape() {
	printf "%s" "$1" | jq -Rrs 'tojson[1:-1]'
}

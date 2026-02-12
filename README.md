<p align="center">
  <img src="https://github.com/Riccardocapelli1/shell-pilot/assets/25558653/7d99c212-4b5c-456d-907d-20df16112cd5" alt="shell-pilot">
</p>

A simple, lightweight shell script to interact with `Groq` or `NVIDIA` APIs from the terminal, enhancing intelligent system management without any dependencies (pure shell).
</div>

## Features


- Use the Groq API for ultra-fast inference with the [Groq Cloud API](https://console.groq.com/) (supports `openai/gpt-oss-120b`, `groq/compound`, etc.)
- Use the NVIDIA API to access extremely powerful models with the [NVIDIA API](https://integrate.api.nvidia.com)
- **Debian Expert Persona**: Built-in system prompt to act as a Debian System Administrator (Italian language supported).
- View your history and session persistence
- Chat context, GPT remembers previous chat questions and answers
- Pass the input prompt with pipe/redirector(`|`, `<`), as a script parameter or normal chat mode(bash version: 4.0+)
- List all available models 
- Set OpenAI request parameters
- Generate a command and run it in terminal, and can use `code chat mode` easy to interact 
- Easy to set the config in command parameter or edit config with vi mode(option e)
- Enhanced system interaction and efficiency with features aimed at basic system management
- `Modular plugin design` allows for easy expansion with each plugin introducing a new functionality, making the tool more powerful and adaptable to user needs.
  - Easy to check system package verison
  - Easy to add/list/remove alias from command line


#### Code chat mode scenario

![code-chat](https://github.com/Riccardocapelli1/shell-pilot/assets/25558653/58eee738-3f54-49c5-a1bb-1ebb87b2f1e5)


#### Vim/vi scenario

![vi-vim-new](https://github.com/Riccardocapelli1/shell-pilot/assets/25558653/f3b97c20-2861-4392-8cc8-c85ccccf2abb)

## Disclaimer

* This is still a test project for using online models and local LLM in shell environment. `It is not production ready, so do not use in critical/production system, and do not use to analyze customer data.`

## Getting Started

### Prerequisites

This script relies on curl for the requests to the api and jq to parse the json response.

* [curl](https://www.curl.se)
  ```sh
  MacOS:
  brew install curl

  Linux: should be installed by default
  dnf/yum/apt install curl
  ```
* [jq](https://stedolan.github.io/jq/)
  ```sh
  MacOS:
  brew install jq

  Linux: should be installed by default
  dnf/yum/apt install jq
  ```
* A Groq API key: Create an account and get a free API Key at [Groq Cloud](https://console.groq.com/keys)
* An NVIDIA API key: Get your API Key at [NVIDIA API Catalog](https://integrate.api.nvidia.com)

* Optionally, you can install [glow](https://github.com/charmbracelet/glow) to render responses in markdown 

### Installation

   - For setup `Ollama` environment, [Manual install instructions](https://github.com/ollama/ollama/blob/main/docs/linux.md), [ollama usage](https://github.com/ollama/ollama), and [Ollama model library](https://ollama.com/library)
   ```sh
   curl -fsSL https://ollama.com/install.sh | sh

   ollama pull llama2  # used llama2 by default
   ```

   - For setup `LocalAI` environment, [Manual](https://localai.io/), and [LocalAI github](https://github.com/mudler/LocalAI)
   ```sh
   docker run -p 8080:8080 --name local-ai -ti localai/localai:latest-aio-cpu
   # Do you have a Nvidia GPUs? Use this instead
   # CUDA 11
   # docker run -p 8080:8080 --gpus all --name local-ai -ti localai/localai:latest-aio-gpu-nvidia-cuda-11
   # CUDA 12
   # docker run -p 8080:8080 --gpus all --name local-ai -ti localai/localai:latest-aio-gpu-nvidia-cuda-12
   ```

   - To install, run this in your terminal and provide your OpenAI API key when asked.
   
   ```sh
   curl -sS -o spilot_install.sh https://raw.githubusercontent.com/Riccardocapelli1/shell-pilot/main/spilot_install.sh
   sudo bash spilot_install.sh
   ```

### Local Installation

   If you have the code locally (cloned via git), you can run the install script directly from the project directory:

   ```sh
   sudo bash spilot_install.sh
   ```

   The script will handle the setup of the configuration files in `/usr/local/bin` (or your preferred path) and initialize the common settings.

   - Set your local `Ollama` server ip in configuration file `spilot_common.sh` if not set during the installation
   ```sh
   OLLAMA_SERVER_IP=<ollama server ip address>
   ```

   - You can also set the other parameters in `spilot_common.sh` before using.
   ```sh
   e.g.
   TEMPERATURE=0.6
   MAX_TOKENS=4096
   MODEL_GROQ=openai/gpt-oss-120b
   MODEL_NVIDIA=mistralai/devstral-2-123b-instruct-2512
   CONTEXT=false
   MULTI_LINE_PROMPT=false
   ENABLE_DANGER_FLAG=false
   ```

### Uninstallation

   To remove Shell Pilot from your system, you can run the uninstaller script:

   ```sh
   # If you have the repo locally
   sudo bash spilot_uninstall.sh

   # Alternatively, download and run it
   curl -sS -o spilot_uninstall.sh https://raw.githubusercontent.com/Riccardocapelli1/shell-pilot/main/spilot_uninstall.sh
   sudo bash spilot_uninstall.sh
   ```

### Testing

   The project includes a basic test suite to verify core functionality (escaping, API request formatting, Groq tool injection).

   To run the tests:
   ```sh
   bash tests/run_tests.sh
   ```

   For integration tests that call the real Groq API, create a `.env` file in the project root:
   ```sh
   echo 'GROQ_API_KEY=your_groq_api_key_here' > .env
   ```

### 🧠 Debian Expert System Prompt (Groq)

When using the Groq API, `s-pilot` acts as a specialized Debian System Administrator. It is optimized to:
- Provide precise Bash commands for Debian Stable.
- Use `apt` for package management.
- Handle paths with proper quoting.
- Include safety warnings for destructive commands.
- Respond in Italian (Italiano) for expert system analysis.

#### 📝 Example Command Execution Workflow

**Request**: `cmd: mostra lo spazio disco libero in modo leggibile`
**s-pilot**: `df -h`
**Execution**:
```text
File system     Dim. Usati Dispon. Uso% Montato su
udev            7.8G     0  7.8G   0% /dev
/dev/nvme0n1p3  476G  120G  332G  27% /
...
```

### Development

   When developing locally, you need to copy your changes to `/usr/local/bin/` to test them:

   ```sh
   # Copy updated scripts to the system path
   sudo cp s-pilot /usr/local/bin/s-pilot
   sudo cp spilot_common.sh /usr/local/bin/spilot_common.sh
   sudo cp spilot_llm_rq_apis.sh /usr/local/bin/spilot_llm_rq_apis.sh
   ```

   **Important**: When running `sudo bash spilot_install.sh`, API keys are added to the **root** user's profile (`/root/.profile`), not your own. To use `s-pilot` as a regular user, add your API key to your own shell profile:

   ```sh
   # Add to your ~/.bashrc or ~/.zshrc
   echo 'export GROQ_API_KEY="your_groq_api_key_here"' >> ~/.bashrc
   source ~/.bashrc
   ```

   **Auto-switching behavior**: If `OLLAMA_SERVER_IP` is not configured but `GROQ_API_KEY` is set, Shell Pilot will automatically use the Groq API instead of failing.

### Manual Installation

  If you want to install it manually, all you have to do is:

  - Download the shell-pilot project files in
  ```shell
  git clone https://github.com/Riccardocapelli1/shell-pilot.git

  cd shell-pilot/
  ```

  - If you want to reset `the script path(/usr/local/bin/ by default)` or `output store path(~/spilot_files_dir by default)`, try below:
  ```shell
  # define the config dir if need to reset
  new_config_path="/new/path/to/config/"
  # define the tmp or output files dir
  new_files_dir="/new/path/to/files/"

  # create it if new
  [[ ! -d ${new_config_path} ]] && mkdir ${new_config_path} -p
  [[ ! -d "${new_config_path}/plugins" ]] && mkdir ${new_config_path}/plugins -p
  [[ ! -d ${new_files_dir} ]] && mkdir ${new_files_dir} -p

  # reset it
  sed -i "s|SHELL_PILOT_CONFIG_PATH=\"/usr/local/bin/\"|SHELL_PILOT_CONFIG_PATH=\"$new_config_path\"|" s-pilot
  sed -i "s|SPILOT_FILES_DEFAULT_DIR=~/spilot_files_dir|SPILOT_FILES_DEFAULT_DIR=$new_files_dir|" spilot_common.sh
  
  # add ollama server host
  ollama_server_ip_address=<ip>
  echo "OLLAMA_SERVER_IP=${ollama_server_ip_address}" >> spilot_common.sh

  # add localai server host
  localai_server_ip_address=<ip>
  echo "LOCALAI_SERVER_IP=${localai_server_ip_address}" >> spilot_common.sh
  ```

  - set the permissions
  ```shell
  chmod +x s-pilot spilot_common.sh spilot_llm_rq_apis.sh plugins/*.sh
  ```

  - Move the files to the dir
  ```shell
  cp s-pilot spilot_common.sh spilot_llm_rq_apis.sh ${new_config_path}

  cp plugins/*.sh ${new_config_path}/plugins
  ```

  - Add settings into the profile file
  ```shell
  # profile, e.g. .bash_profile
  the_profile_file=$HOME/.bash_profile

  # add the script/config path
  echo "export PATH\=\$PATH\:${new_config_path}" >> $the_profile_file

  # add source alias for alias option
  echo "alias ss-pilot='source s-pilot'" >> $the_profile_file

  # Groq API
  groq_api_key_value=<key>
  echo "export GROQ_API_KEY=${groq_api_key_value}" >> $the_profile_file

  # NVIDIA API
  nvidia_api_key_value=<key>
  echo "export NVIDIA_API_KEY=${nvidia_api_key_value}" >> $the_profile_file

  source $the_profile_file
  ```

## Usage

### Start

#### Chat Mode
  - Run the script by using the `s-pilot` command anywhere:
  ```shell
  $ s-pilot
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  ```

#### Pipe Mode
  - You can also use it in pipe mode:
  ```shell
  $ echo "How to view running processes on RHEL8?" | s-pilot

  You can view running processes on RHEL8 using the `ps` command. To see a list of running processes,
  open a terminal and type `ps aux` or `ps -ef`. This will display a list of all processes currently
  running on your system.


  $ cat error.log | s-pilot

  The log entries indicate the following events on the system:

  1. April 7, 23:35:40: Log rotation initiated by systemd, then completed successfully.
  2. April 8, 05:20:51: Error encountered during metadata download for repository
  ```

#### Use Redirection Operators
  ```shell

  $ s-pilot < ss.sh
  The output will be:
  Hello World test

  $ s-pilot p "summarize" < ss.sh
  This is a bash script that defines and invokes a function named "Hello".
  The function takes two arguments, $1 and $2, and prints "Hello World" followed by these arguments...

  $ s-pilot <<< "what is the best way to learn shell? Provide an example"
  The best way to learn shell scripting is through hands-on practice and tutorials. Start by
  understanding basic commands, then move on to writing simple scripts to automate tasks...

  $ s-pilot << EOF
  > how to learn python?
  > provide a detail example.
  > EOF
  To learn Python, follow these steps:
  1. **Understand the Basics**: Start with Python syntax, data types, variables, and basic operations.
  2. **Control Structures**: Learn about loops (for, while), if statements, and functions...
  ```

#### Script Parameters

  - Help with `h`, `-h`, `--help`:

  - Check version:
  ```shell
  s-pilot v
  [Shell Pilot Version]: 1.5.5
  ```

  -  Chat mode with initial prompt:
  ```shell
  s-pilot ip "You are Linux Master. You should provide a detail and professional suggeston about Linux every time."
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  what is shell?


  <<ShellPilot>> A shell is a command-line interface that allows users to interact with the
  operating system by running commands. It is a program that takes input from the user in the form of
  commands and then executes them. The shell acts as an intermediary between the user and the
  operating system, interpreting commands and running programs. There are different types of shells
  available in Linux, such as bash (Bourne Again Shell), sh (Bourne Shell), csh (C Shell), ksh (Korn
  Shell), and more. Each shell has its own set of features and capabilities, but they all serve the
  same fundamental purpose of allowing users to interact with the system via the command line.
  ```

  - with `p`:
  ```shell
  s-pilot -p "What is the regex to match an ip address?"

  The regex to match an IP address is:
  (?:\d{1,3}\.){3}\d{1,3}


  $ cat error.log | s-pilot p "find the errors and provide solution"

  Errors:
  1. Inconsistent date formats: "Apr 7" and "Apr 8".
  2. Inconsistency in log times: "23:35:40" and "10:03:28" for the same date.

  Solutions:
  1. Standardize date format: Use a consistent date format throughout the log entries.
  2. Ensure log times are in chronological order within the same date.
  ```

  - change model provider:
  ```shell

  s-pilot cmp ollama
  Attempting to update USE_API to ollama.
  Backup file removed after successful update.
  The setting will save in the configuration file.

  Here is the checklist to change the model provider:
  USE_API=ollama
  ```

  - list models:
  ```shell
  s-pilot lm

  {
    "name": "llama2:13b",
    "size": "6.86 GB",
    "format": "gguf",
    "parameter_size": "13B",
    "quantization_level": "Q4_0"
  }
  ```

  - list config
  ```shell
  s-pilot lc
  # Configuration settings
  USE_API=ollama

  # Define prompts using the adjusted settings
  CHAT_INIT_PROMPT="You are $MODEL_NAME, a Large Language Model trained by $ORGANIZATION. You will be answering questions from users. Answer as concisely as possible for each response.
  ...
  ```

  - Update the chat setting in `spilot_common.sh`
  ```shell
  s-pilot t 0.9
  Attempting to update TEMPERATURE to 0.9.
  Backup file removed after successful update.
  The setting will save in the configuration file.

  Here is the checklist to change the temperature:
  TEMPERATURE=0.9
  ```

### Commands

  - `history` To view your chat history, type `history`
  ```shell
  $ s-pilot
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  history

  2024-04-08 18:51 hi
  Hello! How can I assist you today?
  ```

  - `models` To get a list of the models available at OpenAI API/Ollama, type `models`
  ```shell
  $ s-pilot
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.
  <<You>>
  models
  {
    "name": "llama2:13b",
    "size": "6.86 GB",
    "format": "gguf",
    "parameter_size": "13B",
    "quantization_level": "Q4_0"
  }
  ```

  - `model:` To view all the information on a specific model, start a prompt with `model:` and the model `id`, please `do not use space between model: and id`,e.g.
  ``` shell
  $ s-pilot
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  model:llama2

  License: LLAMA 2 COMMUNITY LICENSE AGREEMENT
  Llama 2 Version Release Date: July 18, 2023
  ...
  Format: gguf
  Family: llama
  Parameter Size: 7B
  Quantization Level: Q4_0
  ```

  - `cmd:` To get a command with the specified functionality and run it, just type `cmd:` and explain what you want to achieve. The script will always ask you if you want to execute the command. i.e.
  *If a command modifies your file system or dowloads external files the script will show a warning before executing, but if the execution flag is disabled by default if found danger.*
  ```shell
  # >>>>>> MacOS
  s-pilot
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  cmd: list the files in /tmp/


  <<ShellPilot>>  ls /tmp
  Would you like to execute it? (Yes/No)
  y

  Executing command: ls /tmp

  com.xx.launchd.xx	com.x.xx		com.xx.out
  com.xx.launchd.xx	com.x.err			powerlog

  # >>>>>> Linux
  <<You>>
  cmd: update my os


  <<ShellPilot>>  sudo dnf update
  Would you like to execute it? (Yes/No)
  n


  # >>>>>> The danger cmd example:
  <<You>>
  cmd: remove the files in /tmp/


  <<ShellPilot>>  rm -r /tmp/*
  Warning: This command can change your file system or download external scripts & data.
  Please do not execute code that you don't understand completely.

  Info: Execution of potentially dangerous commands has been disabled.
  ```

### Session persistence
  - One-shot Command Mode
  ```shell
  # s-pilot cr test  p "please remember my lucky number is 5"

  I've noted that your lucky number is 5!
  
  # s-pilot lr
  ==> Here are the chat record files[<name>-chat_record.spilot]:
  -rw-r--r--. 1 root root 149 Apr 28 10:07 test-chat_record.spilot

  # s-pilot lr test
  ==> Here is the chat record file content:
  [
    {
      "role": "user",
      "content": "please remember my lucky number is 5\n"
    },
    {
      "role": "assistant",
      "content": "I've noted that your lucky number is 5!\n"
    }
  ]

  # s-pilot cr test  p "use my lucky number plus 20"

  Using your lucky number (5) + 20 gives us... 25!


  # s-pilot dr test
  rm: remove regular file '/root/spilot_files_dir/test-chat_record.spilot'? y
  File /root/spilot_files_dir/test-chat_record.spilot has been deleted successfully.
  ```

  - Interactive Session Mode
  ```shell

  # s-pilot cr test1
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  please remember my favorite color is blue


  <<ShellPilot>> I've made a note that your favorite color is blue!

  <<You>>
  q # quit

  # s-pilot cr test1
  Welcome to Shell Pilot!!
  You can quit with 'q' or 'e'.

  <<You>>
  what is my favorite color?


  <<ShellPilot>> Your favorite color is blue!
  ```

### Chat context

  - For models other than `gpt-3.5-turbo` and `gpt-4` where the chat context is not supported by the OpenAI api, you can use the chat context build in this script. You can enable chat context mode for the model to remember your previous chat questions and answers. This way you can ask follow-up questions. In chat context the model gets a prompt to act as ChatGPT and is aware of today's date and that it's trained with data up until 2021. To enable this mode start the script with  `c`, `-c` or `--chat-context`. i.e. `s-pilot c true` to enable it. 

#### Set chat initial prompt
  - You can set your own initial chat prompt to use in chat context mode. The initial prompt will be sent on every request along with your regular prompt so that the OpenAI model will "stay in character". To set your own custom initial chat prompt use `ip` `-ip` or `--init-prompt` followed by your initial prompt i.e. see the `Script Parameters` usage example.
  - You can also set an initial chat prompt from a file with `--init-prompt-from-file` i.e. `s-pilot --init-prompt-from-file myprompt.txt`
  
  *When you set an initial prompt you don't need to enable the chat context. 

### Use the official  model

  - The default model used when starting the script is `gpt-3.5-turbo` for OpenAI.
  
  - The default model used when starting the script is `llama2` for Ollama.

  - The default model used when starting the script is `mistral-small` for MistralAI.

  - The default model used when starting the script is `openai/gpt-oss-120b` for Groq.

  - The default model used when starting the script is `mistralai/devstral-2-123b-instruct-2512` for NVIDIA.
  
### Use other models for OpenAI or Ollama
  - If you have access to the GPT4 model you can use it by setting the model to `gpt-4`, i.e. `s-pilot --model gpt-4`.

  - For `Ollama`, you can pull first from the ollama server, i.e. `ollama pull mistral`, `s-pilot e` to set.

  - For `MistralAI`, you can check with `s-pilot lm`, and set with `s-pilot e`.

  - For `Groq`, you can use extremely fast models like `openai/gpt-oss-120b` or `openai/gpt-oss-20b`. You can also use **Compound Models** with built-in tools (web search, code interpreter):
    - `groq/compound`
    - `groq/compound-mini`
    Example: `s-pilot m groq/compound` (Shell Pilot automatically enables the required tool configurations).

  - For `NVIDIA`, you can use the `mistralai/devstral-2-123b-instruct-2512` model or other available models.
    Example: `s-pilot cmp nvidia` or `s-pilot m stepfun-ai/step-3.5-flash`.

### Set request parameters

  - To set request parameters you can start the script like this: `s-pilot t 0.9`.
  - The setting will save in `spilot_common.sh`, no need to change or mention every time.
  
    The available parameters are: 
      - temperature, `t` or  `-t` or `--temperature`
      - model, `m` or `-m` or `--model`
      - max number of tokens,`mt`, `-mt`, `--max-tokens`
      - prompt, `p`, `-p` or `--prompt` 
      - prompt from a file in your file system, `pf` or `-pf` or `--prompt-from-file`  
      
    For OpenAI: [OpenAI API documentation](https://platform.openai.com/docs/api-reference/completions/create)
    For Ollama: [Ollama API documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)


### Plugins

  - pv: check the system package version(so far support MacOS/RHEL/CentOS/Fedora)
  ```shell
  $ s-pilot pv
  Check the system package version
  Usage: /usr/local/bin/s-pilot pv [-f] <pkg1> [pkg2] ...

  $ s-pilot pv bc go xx
  Check the system package version
  ✔ bc version 6.5.0
  ✔ go version 1.19.6
  ✗ Package xx not found on macOS.

  $ s-pilot pv -f usb
  Check the system package version
  ✔ libusb version 1.0.27
  ✔ usb.ids version 2024.03.18
  ✔ usbredir version 0.14.0
  ```
  - sa: manage the system alias
  ```shell
  # use `ss-pilot` to execute(not `s-pilot`), it will set it after installation

  # ss-pilot sa a lx "ls -l /tmp/" lxx "ls -ld /etc" cdetc "cd /etc"
  ==> Alias 'lx' added to /root/spilot_files_dir/shell_pilot_system_aliases and is active.
  ==> Alias 'lxx' added to /root/spilot_files_dir/shell_pilot_system_aliases and is active.
  ==> Alias 'cdetc' added to /root/spilot_files_dir/shell_pilot_system_aliases and is active.

  # ss-pilot sa l
  ==> Aliase List:
  alias lx='ls -l /tmp/'
  alias lxx='ls -ld /etc'
  alias cdetc='cd /etc'

  # lx
  total 0
  # cdetc
  # pwd
  /etc

  # ss-pilot sa r lx lxx cdetc
  ==> Alias 'lx' removed from /root/spilot_files_dir/shell_pilot_system_aliases
  ==> Alias 'lxx' removed from /root/spilot_files_dir/shell_pilot_system_aliases
  ==> Alias 'cdetc' removed from /root/spilot_files_dir/shell_pilot_system_aliases

  # lx
  -bash: lx: command not found
  ```

### Acknowledgements

The following projects are worth remarking.
They were studied during development of this script and used as referencial code sources.

1. [0xacx's chatGPT-shell-cli](https://github.com/0xacx/chatGPT-shell-cli)
2. [Ollama](https://github.com/ollama/ollama/)

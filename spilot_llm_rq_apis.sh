#!/usr/bin/env bash
# This script is used to call the APIs of the SPilot LLM service.
# request to OpenAI API/ollama/mistral completions endpoint function
# $1 should be the request prompt
request_to_completions() {
	local prompt="$1"

	if [[ "$USE_API" == "groq" ]]
	then
		curl https://api.groq.com/openai/v1/chat/completions \
		-sS \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer $GROQ_API_KEY" \
		-d '{
			"model": "'"$MODEL_GROQ"'",
			"messages": [
				{"role": "user", "content": "'"$prompt"'"}
				],
			"max_completion_tokens": '$MAX_TOKENS',
			"temperature": '$TEMPERATURE'
			}'
	elif [[ "$USE_API" == "nvidia" ]]
	then
		curl https://integrate.api.nvidia.com/v1/chat/completions \
		-sS \
		-H 'Content-Type: application/json' \
		-H "Authorization: Bearer $NVIDIA_API_KEY" \
		-d '{
			"model": "'"$MODEL_NVIDIA"'",
			"messages": [
				{"role": "user", "content": "'"$prompt"'"}
				],
			"max_tokens": '$MAX_TOKENS',
			"temperature": '$TEMPERATURE'
			}'
	else
		echo "Error: No API specified".
		exit 1
	fi
}

# request to OpenAPI API/ollama/mistral chat completion endpoint function
# $1 should be the message(s) formatted with role and content
request_to_chat() {
	local message="$1"
	escaped_system_prompt=$(escape "$SYSTEM_PROMPT")
	
	if [[ "$USE_API" == "groq" ]]
	then
		local compound_custom=""
		if [[ "$MODEL_GROQ" == "groq/compound" || "$MODEL_GROQ" == "groq/compound-mini" ]]; then
			compound_custom=', "compound_custom": {"tools": {"enabled_tools": ["web_search", "code_interpreter", "visit_website"]}}'
		fi
		curl https://api.groq.com/openai/v1/chat/completions \
		-sS \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $GROQ_API_KEY" \
		-d '{
			"model": "'"$MODEL_GROQ"'",
			"messages": [
				{"role": "system", "content": "'"$escaped_system_prompt"'"},
				'"$message"'
				],
			"max_completion_tokens": '$MAX_TOKENS',
			"temperature": '$TEMPERATURE',
			"stream": false
			'"$compound_custom"'
		}'
	elif [[ "$USE_API" == "nvidia" ]]
	then
		curl https://integrate.api.nvidia.com/v1/chat/completions \
		-sS \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $NVIDIA_API_KEY" \
		-d '{
			"model": "'"$MODEL_NVIDIA"'",
			"messages": [
				{"role": "system", "content": "'"$escaped_system_prompt"'"},
				'"$message"'
				],
			"max_tokens": '$MAX_TOKENS',
			"temperature": '$TEMPERATURE',
			"stream": false
		}'
	else
		echo "Error: No API specified".
		exit 1
	fi
}

fetch_model_from_groq(){
    curl https://api.groq.com/openai/v1/models \
    -sS \
    -H "Authorization: Bearer $GROQ_API_KEY"
}

fetch_model_from_nvidia(){
    curl https://integrate.api.nvidia.com/v1/models \
    -sS \
    -H "Authorization: Bearer $NVIDIA_API_KEY"
}
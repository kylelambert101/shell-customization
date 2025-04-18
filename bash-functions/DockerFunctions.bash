#!/bin/bash

# Define colors
BLUE="\033[34m"
CYAN="\033[36m"
DARKGREY="\033[90m"
GREEN="\033[32m"
GREY="\033[37m"
MAGENTA="\033[35m"
RED="\033[31m"
RESET="\033[0m"
YELLOW="\033[93m"

# Function: process-logs
# Description:
#   Processes logs from a stream or file. If the log lines are in structured JSON format,
#   they will be parsed and displayed as [LogLevel] Message. If the log line is not in
#   JSON format, it will be displayed as is.
# Options:
#   -t, --timestamps   Include timestamps in the output if provide in the JSON.
#   --help             Display this help message and exit.
process-logs() {
  local show_timestamps=false

  # Display help text
  if [[ "$1" == "--help" ]]; then
    echo "Usage: process-logs [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --timestamps   Include timestamps in the output."
    echo "  --help             Display this help message and exit."
    return 0
  fi

  # Parse optional arguments
  while [[ "$1" != "" ]]; do
    case "$1" in
      -t|--timestamps)
        show_timestamps=true
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use --help to see available options."
        return 1
        ;;
    esac
    shift
  done

  while IFS= read -r line; do
    # Default values
    local log_level="UNKNOWN"
    local timestamp=""
    local message="$line"

    # Parse JSON if possible
    if echo "$line" | jq . >/dev/null 2>&1; then
      timestamp=$(echo "$line" | jq -r '.timestamp // empty')
      log_level=$(echo "$line" | jq -r '.logLevel // "UNKNOWN"')
      message=$(echo "$line" | jq -r '.message // empty')
    fi

    # Determine log level color
    local log_level_color=$RESET
    local message_color=$RESET
    case "$log_level" in
      INFO) log_level_color=$CYAN ;;
      WARN) log_level_color=$YELLOW; message_color=$YELLOW ;;
      ERROR) log_level_color=$RED; message_color=$RED ;;
      DEBUG) log_level_color=$MAGENTA ;;
      UNKNOWN) log_level_color=$GREY; message_color=$GREY; log_level="" ;;
    esac

    # Format and print the log line
    if [[ "$show_timestamps" == true && -n "$timestamp" ]]; then
      printf "%b%s%b " "$DARKGREY" "$timestamp" "$RESET"
    fi
    if [[ -n "$log_level" ]]; then
      printf "[%b%s%b] " "$log_level_color" "$log_level" "$RESET"
    fi
    printf "%b%s%b\n" "$message_color" "$message" "$RESET"
  done
}

# Function: docker-logs
# Description:
#   Streams logs from a Docker container, filtering by a partial container name.
#   If multiple containers match the provided name, the user is prompted to refine
#   their search. If exactly one container matches, its logs are streamed into the
#   process-logs function.
# Options:
#   -t, --timestamps   Include timestamps in the output if provided in the JSON.
#   --help             Display this help message and exit.
# Arguments:
#   <container-name-part>   A part of the container name to match.
docker-logs() { 
  local show_timestamps=false
  local container_name_part=""

  # Display help text
  if [[ "$1" == "--help" ]]; then
    echo "Usage: docker-logs [OPTIONS] <container-name-part>"
    echo ""
    echo "Options:"
    echo "  -t, --timestamps   Include timestamps in the output."
    echo "  --help             Display this help message and exit."
    return 0
  fi

  # Parse optional arguments
  while [[ "$1" != "" ]]; do
    case "$1" in
      -t|--timestamps)
        show_timestamps=true
        ;;
      *)
        if [[ -z "$container_name_part" ]]; then
          container_name_part="$1"
        else
          echo "Unknown option or extra argument: $1"
          echo "Usage: docker-logs [-t|--timestamps] <container-name-part>"
          return 1
        fi
        ;;
    esac
    shift
  done

  # Ensure a container name part is provided
  if [[ -z "$container_name_part" ]]; then
    printf "%bError: You must provide a part of the container name.%b\n" "$RED" "$RESET"
    echo "Usage: docker-logs [-t|--timestamps] <container-name-part>"
    return 1
  fi

  # Find matching containers
  local matching_containers
  matching_containers=$(docker ps -a --format "{{.ID}} {{.Names}} {{.Image}}" | grep "$container_name_part" || true)

  # Check if there are no matches
  if [[ -z "$matching_containers" ]]; then
      printf "%bNo containers found matching '%s'.%b\n" "$RED" "$container_name_part" "$RESET"
      return 1
  fi

  # Check the number of matches
  local match_count
  match_count=$(echo "$matching_containers" | wc -l | tr -d ' ')

  if [[ "$match_count" -gt 1 ]]; then
      printf "%bMultiple containers found matching '%s':%b\n" "$RED" "$container_name_part" "$RESET"
      while IFS= read -r container; do
          # Split the container info into ID and name
          local container_id=$(echo "$container" | awk '{print $1}')
          local container_name=$(echo "$container" | awk '{print $2}')
          
          # Highlight the matching part in the container name
          local highlighted_name=$(echo "$container_name" | sed "s/$container_name_part/\\$GREEN&\\$RESET/g")
          # Print the formatted container info
          printf " * %s %b\n" "$container_id" "$highlighted_name"
      done <<< "$matching_containers"
      printf "\n%bTry again with a more specific name.%b\n" "$RED" "$RESET"
      return 1
  fi

  # Extract the container ID and name
  local container_id
  local container_name
  container_id=$(echo "$matching_containers" | awk '{print $1}')
  container_name=$(echo "$matching_containers" | awk '{print $2}')

  # Print container info
  printf "%b === Logs for container %s (%s) === %b\n" "$GREEN" "$container_id" "$container_name" "$RESET"

  # Run docker logs and pipe through process-logs
  if [[ "$show_timestamps" == true ]]; then
    docker logs -f "$container_id" 2>&1 | process-logs --timestamps
  else
    docker logs -f "$container_id" 2>&1 | process-logs
  fi
}
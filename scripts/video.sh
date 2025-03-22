#!/bin/bash

# Trap Ctrl+C (SIGINT) to exit the script gracefully.
trap 'printf "\nExiting...\n"; exit 0' SIGINT

# Store the previous search term.
query=""

while true; do
    # fzf's --print-query prints the final query on the first line, followed by the selected item.
    # Use a temporary file or a variable to capture the output.
    result=$(fzf --query "$query" \
                 --delimiter=$'\n' \
                 --with-nth=1 \
                 --prompt="Search video> " \
                 --print-query \
                 --bind "ctrl-c:abort")

    # Check if fzf returned anything.
    if [[ -z "$result" ]]; then
        printf "\nNo file selected. Exiting...\n"
        exit 0
    fi

    # Read the fzf output: the first line is the query and subsequent lines are the selected entries.
    # We use a here-string to read the result into an array.
    IFS=$'\n' read -r -d '' -a lines <<< "$result"$'\0'

    # The first line contains the query.
    query="${lines[0]}"

    # The rest of the lines (if any) are the selections. We'll use the first selection.
    if [[ ${#lines[@]} -ge 2 ]]; then
        file="${lines[1]}"
    else
        # If nothing was selected beyond the query, exit.
        printf "\nNo file selected. Exiting...\n"
        exit 0
    fi

    # Check if the selected file exists and is a regular file.
    if [[ -f "$file" ]]; then
        # Play the file with mpv. This blocks until mpv is closed.
        mpv "$file"
    else
        printf "Selected file does not exist or is not a regular file: %s\n" "$file"
    fi
done

#!/bin/bash

SESSION="mypaper"
DIR="/home/loncelot/Games/paper"
JAR="paper-1.12.2-1620.jar"

# Check if tmux session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? -eq 0 ]; then
    # Session exists, reattach
    tmux attach-session -t $SESSION
else
    # Session does not exist, create it
    tmux new-session -d -s $SESSION
    tmux send-keys -t $SESSION "cd $DIR" C-m

    # Check if Java server is already running
    if ! pgrep -f "$JAR" > /dev/null; then
        tmux send-keys -t $SESSION "java -jar -Xmx6G $JAR" C-m
    fi

    # Attach to the new session
    tmux attach-session -t $SESSION
fi
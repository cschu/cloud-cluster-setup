#!/bin/sh

tmux new-session -d "sudo -i"

tmux split-window -d -h "ssh bibigrid-worker-1-1-e5kpwvuhqxscjba"
tmux select-pane -t 1
tmux send-keys "sudo -i ; exit" Enter

tmux split-window -d -h "ssh bibigrid-worker-2-1-e5kpwvuhqxscjba"
tmux select-pane -t 2
tmux send-keys "sudo -i ; exit" Enter

tmux split-window -d -h "ssh bibigrid-worker-2-2-e5kpwvuhqxscjba"
tmux select-pane -t 3
tmux send-keys "sudo -i ; exit" Enter

tmux split-window -d -h "ssh bibigrid-worker-3-1-e5kpwvuhqxscjba"
tmux select-pane -t 4
tmux send-keys "sudo -i ; exit" Enter

tmux select-pane -t 4
tmux select-layout tiled
tmux set-window-option synchronize-panes on
tmux attach

#!/bin/bash

git reset --soft HEAD~1 && \
sudo git restore *myvpn.sh && \
sudo git restore *myvm.sh && \
git restore --staged . && \
sudo git add . && \
git commit -m "todo" && \
git push -f
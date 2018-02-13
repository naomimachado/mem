#!/bin/bash

export PORT=5103

cd ~/www/memory
./bin/memory stop || true
./bin/memory start


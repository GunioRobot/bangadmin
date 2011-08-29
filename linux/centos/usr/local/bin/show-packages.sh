#!/usr/bin/env bash

# Usage ./show-packages.sh epel
repoquery --repoid=$1 -a | xargs yum list installed

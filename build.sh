#!/bin/bash
set -euo pipefail

for src in ./src/as/*; do
  (
    cd "$src"

    if [ "$(cat ./res/source.json | grep 'deprecated' | awk '{print $2}')" == "true" ]; then
      rm -rf ./build/package.aix
    else
      npm run build
    fi
  )
done

for src in ./src/rust/*; do
  (
    cd "$src"

    if [ "$(cat ./res/source.json | grep 'deprecated' | awk '{print $2}')" == "true" ]; then
      rm -rf ./package.aix
    else
      ./build.sh -a
    fi
  )
done

shopt -s globstar nullglob
packages=(./src/**/*.aix)
if ((${#packages[@]} == 0)); then
  echo "No .aix source packages were built" >&2
  exit 1
fi

aidoku build "${packages[@]}"

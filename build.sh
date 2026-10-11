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

source_index=$(mktemp)
cp public/index.json "$source_index"
aidoku build "${packages[@]}"

mkdir -p public/sources public/icons
cp src/rust/zh.baozimh2/package.aix public/sources/zh.baozimh2-v7.aix
cp src/rust/zh.baozimh2/res/Icon.png public/icons/zh.baozimh2-v7.png
jq '
  if any(.[]; .id == "zh.baozimh2") then
    map(if .id == "zh.baozimh2" then
      .name = "佳佳包子漫画v7" |
      .file = "zh.baozimh2-v7.aix" |
      .icon = "zh.baozimh2-v7.png" |
      .version = 7
    else . end)
  else
    . + [{
      "id": "zh.baozimh2",
      "name": "佳佳包子漫画v7",
      "file": "zh.baozimh2-v7.aix",
      "icon": "zh.baozimh2-v7.png",
      "lang": "zh",
      "version": 7,
      "nsfw": 0
    }]
  end
' "$source_index" > public/index.json
jq -c . public/index.json > public/index.min.json
rm -f "$source_index"

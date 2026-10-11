#!/bin/bash
set -euo pipefail

source_dir="./src/rust/zh.baozimh2"

(
  cd "$source_dir"
  ./build.sh -a
)

package="$source_dir/package.aix"
if [[ ! -f "$package" ]]; then
  echo "Baozi source package was not built: $package" >&2
  exit 1
fi

# Start with a clean catalog so no previous source packages remain published.
rm -rf public/sources public/icons
mkdir -p public/sources public/icons

aidoku build "$package"

cp "$package" public/sources/zh.baozimh2-v7.aix
cp "$source_dir/res/Icon.png" public/icons/zh.baozimh2-v7.png

cat > public/index.json <<'JSON'
[
  {
    "id": "zh.baozimh2",
    "name": "佳佳包子漫画v7",
    "file": "zh.baozimh2-v7.aix",
    "icon": "zh.baozimh2-v7.png",
    "lang": "zh",
    "version": 7,
    "nsfw": 0
  }
]
JSON

jq -c . public/index.json > public/index.min.json

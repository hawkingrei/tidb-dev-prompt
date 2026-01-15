#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: fetch.sh <url>" >&2
  exit 2
fi

url="$1"
cache_dir=".llms-cache"
mkdir -p "$cache_dir"

slug="$(python3 - <<'PY'
import hashlib,sys
url=sys.argv[1]
print(hashlib.sha256(url.encode("utf-8")).hexdigest()[:16])
PY
"$url")"

out="$cache_dir/$slug.txt"

if [[ -s "$out" ]]; then
  echo "$out"
  exit 0
fi

curl -fsSL --max-time 60 "$url" -o "$out"
echo "$out"


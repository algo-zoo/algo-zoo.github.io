#!/bin/sh
npx rescript build
for x in rescript/*.js; do
  if [[ "$(basename "$x")" != "concave-hull.js" ]]; then
    npx parcel build "$x" --no-scope-hoist
  fi
done
cp rescript/concave-hull.js static/js
# hugo --gc --minify build
# find public -type f -name "*.html" | while read -r file; do
#   tidy -quiet -indent --wrap 0 -modify "$file" 2>/dev/null
#   echo "Prettify: $file"
# done

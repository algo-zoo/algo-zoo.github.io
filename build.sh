#!/bin/sh
npx tailwindcss -c assets/css/tailwind.config.js \
  -i assets/css/styles.css -o assets/css/generated.css --minify
npx rescript build
if [ "$#" -eq 1 ]; then
  npx parcel build $1 --no-scope-hoist
else
  for x in rescript/*.js; do
    if [ "$(basename "$x")" != "concave-hull.js" ]; then
      npx parcel build "$x" --no-scope-hoist
    fi
  done
fi
cp rescript/concave-hull.js static/js

#!/bin/sh
hugo --minify build
find public -type f -name "*.html" | while read -r file; do
  tidy -quiet -indent --wrap 0 -modify "$file" 2>/dev/null
  echo "Prettify: $file"
done

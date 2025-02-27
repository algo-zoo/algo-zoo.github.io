#!/bin/sh
npx rescript build
find static/js -type f -name "*.js" -exec sed -i 's|rescript/lib/es6/|../rescript-lib/|g' {} +
hugo --gc --minify build
find public -type f -name "*.html" | while read -r file; do
  tidy -quiet -indent --wrap 0 -modify "$file" 2>/dev/null
  echo "Prettify: $file"
done

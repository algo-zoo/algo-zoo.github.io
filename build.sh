#!/bin/sh
npx tailwindcss -c assets/css/tailwind.config.js \
  -i assets/css/styles.css -o assets/css/generated.css --minify
npx rescript build
# rescript/*.js のバンドルは hugo の js.Build が行う (layouts/partials/head.html)。
# concave-hull.js だけはバンドル対象外の素の script なので static/ から配る。
mkdir -p static/js
cp rescript/concave-hull.js static/js

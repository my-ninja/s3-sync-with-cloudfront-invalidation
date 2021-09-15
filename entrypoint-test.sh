#!/bin/sh
set -e

if [ "$COMPILE_JS" == "both" ] || [ "$COMPILE_JS" == "min" ]; then
  for f in $(find ${SOURCE_DIR} -name '*.js'); do 
    c=$(basename "$f" ".js")
    d=$(dirname "$f")
    output=$d/$c.min.js
    
    #echo "closure-compiler --js $f --js_output_file $output"
    closure-compiler --js $f --js_output_file $output
    if [ "$COMPILE_JS" == "min" ]; then
      mv -f $output $f
    fi
    ls -la ${SOURCE_DIR}
    cat $f
  done
fi

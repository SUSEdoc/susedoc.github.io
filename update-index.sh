#!/bin/bash
# Update index.html for susedoc.github.io
# Usage: Just run this script, without arguments
#   update-index.sh


me="$(test -L $(realpath $0) && readlink $(realpath $0) || echo $(realpath $0))"
mydir="$(dirname $me)"

if [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
  sed -rn '/#!/{n; p; :loop n; p; /^[ \t]*$/q; b loop}' $0 | sed -r 's/^# ?//'
  exit
fi

sourcedir=$mydir
copydir=$mydir

xsltproc "$mydir/update-index.xsl" "$sourcedir/index-config.xml" > "$copydir/index.html"

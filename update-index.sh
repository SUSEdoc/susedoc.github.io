#!/bin/bash
# Update index.html for susedoc.github.io
# Usage: This script runs without arguments
#   update-index.sh
# However, Travis will run this script for you. Just let it do that.


me="$(test -L $(realpath $0) && readlink $(realpath $0) || echo $(realpath $0))"
mydir="$(dirname $me)"

if [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
  sed -rn '/#!/{n; p; :loop n; p; /^[ \t]*$/q; b loop}' $0 | sed -r 's/^# ?//'
  exit
fi

if [[ ! $I_AM_A_MACHINE -eq 1 ]]; then
  echo "Have Travis run this script and do not run it manually. Thank you."
  echo "If you do need to run it manually, run:"
  echo "  I_AM_A_MACHINE=1 $0"
  exit 1
fi

sourcedir=$mydir
copydir=$mydir

xmllint --noout --noent --dtdvalid $mydir/config.dtd $mydir/index-config.xml 2>&1
code=$?
echo -e "\n"
[[ $code -eq 0 ]] || {
  echo "index-config.xml does not validate."
  exit 1
}
xsltproc "$mydir/update-index.xsl" "$sourcedir/index-config.xml" > "$copydir/index.html"

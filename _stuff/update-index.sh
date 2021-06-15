#!/bin/bash
# Update index.html for susedoc.github.io
# Usage: This script runs without arguments
#   update-index.sh
# However, Travis will run this script for you. Just let it do that.


me="$(test -L $(realpath $0) && readlink $(realpath $0) || echo $(realpath $0))"
mydir="$(dirname $me)"
configdir=$mydir/..

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

sourcedir=$configdir
copydir=$configdir

xmllint --noout --noent --dtdvalid $mydir/config.dtd $configdir/config.xml 2>&1
code=$?

redirect_from=$(xml sel -t -v '//redirect/@from' $configdir/config.xml)
redirect_to=$(xml sel -t -v '//redirect/@to' $configdir/config.xml)

# only allow very simple constructs here
if [[ $(echo -e "$redirect_from" | grep -P '[^-_.a-zA-Z0-9]') ]]; then
  echo "Redirect 'from' is not simple enough (-_.a-zA-Z0-9)."
  code=$(( $code + 1))
fi
# make sure all redirect froms are only defined once
if [[ $(echo -e "$redirect_from" | sort) != $(echo -e "$redirect_from" | sort -u) ]]; then
  echo "Redirect 'from' values must be unique."
  code=$(( $code + 1))
fi
# only relative links allowed
if [[ $(echo -e "$redirect_to" | grep -P '^(https?://|s?ftps?://|/|mailto:|file:)') ]]; then
  echo "Redirect 'to' must be relative."
  code=$(( $code + 1))
fi


echo -e "\n"
[[ $code -eq 0 ]] || {
  echo "config.xml does not validate."
  exit 1
}
xsltproc "$mydir/update-index.xsl" "$sourcedir/config.xml" > "$copydir/index.html"

# Add a dir for redirect links (let's make the name short)
rm -rf "$configdir/r"
mkdir -p "$configdir/r"

len=$(echo -e "$redirect_from" | wc -l)

n=0
for l in $(seq 1 $len); do
  from=$(echo -e "$redirect_from" | sed -n "$l p")
  to=$(echo -e "$redirect_to" | sed -n "$l p")
  mkdir -p "$configdir/r/$from"
  echo '<html><head><meta http-equiv="refresh" content="0;URL='"'https://susedoc.github.io/$to'"'"></head><title>Redirect</title><body><a href="'"https://susedoc.github.io/$to"'">'"$to"'</a></body></html>' > "$configdir/r/$from/index.html"
done

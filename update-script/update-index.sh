#!/bin/bash
# Update index.html for susedoc.github.io
# Usage:
#   update-index.sh [config.xml] [schema.dtd] [output_dir]
# However, GitHub Actions will normally run this script for you.


# shellcheck disable=SC2046,SC2086,SC2005
me="$(test -L $(realpath $0) && readlink $(realpath $0) || echo $(realpath $0))"
mydir="$(dirname $me)"

if [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
  sed -rn '/#!/{n; p; :loop n; p; /^[ \t]*$/q; b loop}' $0 | sed -r 's/^# ?//'
  exit
fi

config="$1"
dtd="$2"
output_dir="$3"

xmllint --noout --noent --dtdvalid "$dtd" "$config" 2>&1
code=$?

redirect_from=$(xml sel -t -v '//redirect/@from' "$config")
redirect_to=$(xml sel -t -v '//redirect/@to' "$config")

# only allow very simple constructs here
# shellcheck disable=SC2143
if [[ $(echo -e "$redirect_from" | grep -P '[^-_.a-zA-Z0-9]') ]]; then
  echo "Redirect 'from' is not simple enough (-_.a-zA-Z0-9)."
  code=$(( code + 1 ))
fi
# make sure all redirect froms are only defined once
if [[ $(echo -e "$redirect_from" | sort) != $(echo -e "$redirect_from" | sort -u) ]]; then
  echo "Redirect 'from' values must be unique."
  code=$(( code + 1 ))
fi
# only relative links allowed
# shellcheck disable=SC2143
if [[ $(echo -e "$redirect_to" | grep -P '^(https?://|s?ftps?://|/|mailto:|file:)') ]]; then
  echo "Redirect 'to' must be relative."
  code=$(( code + 1 ))
fi


echo -e "\n"
[[ $code -eq 0 ]] || {
  echo "config.xml does not validate."
  exit 1
}
xsltproc "$mydir/update-index.xsl" "$config" > "$output_dir/index.html"

# Add a dir for redirect links (let's make the name short)
rm -rf "$output_dir/r"
mkdir -p "$output_dir/r"

len=$(echo -e "$redirect_from" | wc -l)

for l in $(seq 1 $len); do
  from=$(echo -e "$redirect_from" | sed -n "$l p")
  to=$(echo -e "$redirect_to" | sed -n "$l p")
  mkdir -p "$output_dir/r/$from"
  echo '<html><head><meta http-equiv="refresh" content="0;URL='"'https://susedoc.github.io/$to'"'"></head><title>Redirect</title><body><a href="'"https://susedoc.github.io/$to"'">'"$to"'</a></body></html>' > "$output_dir/r/$from/index.html"
done

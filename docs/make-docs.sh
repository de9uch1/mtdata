#!/usr/bin/env bash
# Author: Thamme Gowda
# Created: Feb 2022

DOCS_DIR="$(dirname "${BASH_SOURCE[0]}")"  # Get the directory name

function my_exit { # my_exit <exit-code> <error-msg>
  echo "$2" 1>&2
  exit "$1"
}

version=$(python -m mtdata -v  2> /dev/null | cut -d' ' -f2 | sed 's/-.*//')   # sed out  -dev -a -b etc
[[ -n $version ]] || my_exit 1 "Unable to parse mtdata version; check: python -m mtdata -v"
echo "mtdata $version"
asciidoctor -v || my_exit 2 "asciidoctor not found; please install and rerun"

ver_dir="${DOCS_DIR}/v${version}"
[[ -d $ver_dir ]] || mkdir -p "$ver_dir"

cmd="asciidoctor -o ${ver_dir}/index.html $DOCS_DIR/index.adoc"
echo "Running:: $cmd"
eval "$cmd" || my_exit 3 "Doc building Failed"

echo "Extracting dataset IDs to $ver_dir/dids.txt"
python -m mtdata -ri list -id | sort > "$ver_dir/dids.txt"

# link version files to top level dir
for fname in index.html dids.txt asciidoctor.css rouge-github.css; do
  [[ -e "$DOCS_DIR/$fname" ]] && rm "$DOCS_DIR/$fname"
  ln -s "v$version/$fname" "$DOCS_DIR/$fname"
done

# search is copied from docs to version dir
cp  "$DOCS_DIR/search.html" "$ver_dir/search.html"

[[ -f $DOCS_DIR/versions.adoc ]] && asciidoctor -o "$DOCS_DIR/versions.html" "$DOCS_DIR/versions.adoc"

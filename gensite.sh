#!/bin/sh --
set -ue; export POSIXLY_CORRECT=1
# BY: Jumps Are Op. (jumpsareop@gmail.com)
# LICENSE: GPLv3-or-later

# CONTENT -> Content directory                	(default content)
# STATIC -> Directory for files to copy as-is 	(default static)
# PUBLIC -> Output directory                  	(default public)
# HEADER -> Program to add it's output before HTML content
# FOTTER -> Program to add it's output after HTML content
# PARSERS -> File containing a list of parsers	(see parsers file)
# NOTE: $1 for HEADER and FOOTER is -- and $2 is the file name

main(){
	: "${CONTENT:=content}${STATIC:=static}${PUBLIC:=public}" \
		"${HEADER:=}${FOOTER:=}${PARSERS:=}"
	PRG=${0##*/}
	echo "--- Generating content ---"
	gencontentdir "$CONTENT"
	echo "--- Copying statics ---"
	set -- "$STATIC"/.*; shift; [ -e "$1" ] && shift
	set -- "$STATIC"/* "$@"; [ ! -e "$1" ] && shift
	[ "$#" != 0 ] && cp -R -- "$@" "$PUBLIC"
}

gencontentdir(){
	[ ! -d "$1" ] && { echo "$PRG: $1: Isn't a directory" >&2; exit 1;}

	mkdir -p -- "$PUBLIC${1#"$CONTENT"}"
	set -- "$1"/*
	[ ! -e "$1" ] && return

	for file;do
		if [ -d "$file" ]
		then gencontentdir "$file"
		else gencontentfile "$file"
		fi
	done
	wait
}

gencontentfile(){
	f=${1#"$CONTENT"} f=$PUBLIC/${f%.*}.html
	ext=${1##*.}
	parser=$(grep -- "^$ext\( \|$\)" "$PARSERS") ||:
	parser=${parser#"$ext"}
	if [ ${parser:+s} ];then
		[ ! "$HEADER" ] || "$HEADER" -- "$1" >"$f"
		(eval "$parser -- \"\$1\"" >>"$f")
		[ ! "$FOOTER" ] || "$FOOTER" -- "$1" >>"$f"
		return
	fi
	cp -- "$1" "${f%.*}.$ext"
}

main "$@"

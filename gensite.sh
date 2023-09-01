#!/bin/sh -fue
# shellcheck disable=SC2086,SC2223
# Made by jumps are op
# This software is under GPL version 3 and comes with ABSOLUTELY NO WARRANTY

# CONFIG_CONTENTDIR -> Content directory                     (default content)
# CONFIG_STATICDIR -> Directory for files to copy as-is       (default static)
# CONFIG_PUBLICDIR -> Output directory                        (default public)
# CONFIG_HEADER -> Program to add it's output before HTML content
# CONFIG_FOTTER -> Program to add it's output after HTML content
# CONFIG_PARSERS -> File containing a list of parsers       (see parsers file)
# CONFIG_MKDIRARGS -> mkdir's arguments
# CONFIG_CPARGS -> cp's arguments
# NOTE: $1 for CONFIG_HEADER and CONFIG_FOOTER is -- and $2 is the file name

main(){
	: ${CONFIG_CONTENTDIR:=content} ${CONFIG_STATICDIR:=static}
	: ${CONFIG_PUBLICDIR:=public} ${CONFIG_HEADER:=} ${CONFIG_FOOTER:=} 
	: ${CONFIG_PARSERS:=} ${CONFIG_MKDIRARGS:=} ${CONFIG_CPARGS:=}
	PRG=${0##*/}
	echo "--- Generating content ---"
	gencontentdir "$CONFIG_CONTENTDIR"
	echo "--- Copying statics ---"
	set +f; set -- "$CONFIG_STATICDIR"/.*; shift; [ -e "$1" ] && shift
	set -f -- "$CONFIG_STATICDIR"/* "$@"; [ ! -e "$1" ] && shift
	[ $# != 0 ] && cp $CONFIG_CPARGS -R -- "$@" "$CONFIG_PUBLICDIR"
}

gencontentdir(){
	:<"$1"
	if [ ! -d "$1" ];then
		echo "$PRG: $1: Isn't a directory" >&2
		exit 1
	fi

	mkdir $CONFIG_MKDIRARGS -p -- "$CONFIG_PUBLICDIR${1#"$CONFIG_CONTENTDIR"}"
	set +f
	set -f -- "$1"/*
	[ ! -e "$1" ] && return

	while :;do
		if [ -d "$1" ]
		then gencontentdir "$1"
		else gencontentfile "${1#"$CONFIG_CONTENTDIR"}"
		fi &

		[ $# = 1 ] && break
		shift
	done
	wait
}

gencontentfile(){
	set -f
	[ "$CONFIG_HEADER" ] && "$CONFIG_HEADER" -- "${CONFIG_CONTENTDIR}$1" \
			>"$CONFIG_PUBLICDIR${1%.*}.html"

	parser=$(grep "^${1##*.}\( \|$\)" -- "$CONFIG_PARSERS")
	parser=${parser#"${1##*.}"}

	(eval "${parser:-echo "$PRG: $1: Unknown file format" >&2; exit 1 #} --" \
		"\"\$CONFIG_CONTENTDIR\$1\"" >>"$CONFIG_PUBLICDIR${1%.*}.html")

	[ "$CONFIG_FOOTER" ] && "$CONFIG_FOOTER" -- "${CONFIG_CONTENTDIR}$1" \
			>>"$CONFIG_PUBLICDIR${1%.*}.html"
}

main "$@"

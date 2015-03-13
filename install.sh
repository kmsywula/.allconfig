#!/bin/sh
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

defaults() {
	echo defaults "$@"
	command defaults "$@"
}

symlink() {
	ln -sf "$@"
}

main() {
	for file in gitconfig; do
		echo $file
		[ -d ~/.$file ] && rm -r ~/."$file"
		symlink "$PWD/$file" ~/."$file"
	done
}

main "$@"

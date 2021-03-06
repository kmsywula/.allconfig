#!/usr/bin/env bash
# Best bashrc in history
#
# Dave Eddy <dave@daveeddy.com>

# If not running interactively, don't do anything
[[ -z $PS1 ]] && return

# Load bics, plugins found in bics-plugins
. ~/.bics/bics || echo '> failed to load bics' >&2

# Set environment
export BROWSER='chromium'
export EDITOR='vim'
export GREP_COLOR='1;36'
export GREP_OPTIONS='--color=auto'
export HISTCONTROL='ignoredups'
export HISTSIZE=5000
export HISTFILESIZE=5000
export LSCOLORS='ExGxbEaECxxEhEhBaDaCaD'
export PAGER='less'
export PATH="$PATH:$HOME/bin:/usr/node/bin"
export SSHP_NO_RAINBOW=1
export SSHP_TRIM=1
export TZ='US/Eastern'
export VISUAL='vim'

# Joyent Manta
export MANTA_USER=${MANTA_USER:-bahamas10}
export MANTA_URL=${MANTA_URL:-https://us-east.manta.joyent.com}
export MANTA_KEY_ID=${MANTA_KEY_ID:-$(ssh-add -l 2>/dev/null | awk '{ print $2 }')}
export MANTA_KEY_ID=${MANTA_KEY_ID:-$(ssh-keygen -l -f ~/.ssh/id_rsa.pub 2>/dev/null | awk '{print $2}')}

# Support colors in less
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# Shell Options
shopt -s cdspell
shopt -s checkwinsize
shopt -s extglob

# Bash Version >= 4
shopt -s autocd   2>/dev/null || true
shopt -s dirspell 2>/dev/null || true

# Aliases
alias ..='echo "cd .."; cd ..'
alias bssh='dns-sd -B _ssh._tcp .'
alias chomd='chmod'
alias externalip='curl -s http://ifconfig.me/ip'
alias gerp='grep'
alias joyentstillpaying="sdc-listmachines | json -a -c \"state !== 'running'\" name state | sort"
alias l='ls -CF'
alias lsdisks='kstat -lc disk :::class | field 3 :'
alias suod='sudo'
alias urldecode="node -pe 'decodeURIComponent(require(\"fs\").readFileSync(\"/dev/stdin\", \"utf-8\"));"
alias urlencode="node -pe 'encodeURIComponent(require(\"fs\").readFileSync(\"/dev/stdin\", \"utf-8\"));"
alias cg='sudo chef-solo -c "$(gr)/solo.rb"'

# Git Aliases
alias nb='git checkout -b "$USER-$(date +%s)"' # new branch
alias ga='git add . --all'
alias gb='git branch'
alias gc='git clone'
alias gci='git commit -a'
alias gcm='git checkout master && git pull'
alias gco='git checkout'
alias gd='git diff'
alias gho='open "$(git config --get remote.origin.url | sed "s/git@github.com:/https:\/\/github.com\//")"'
alias gi='git init'
alias gl='git log'
alias gmm='git merge master'
alias gp='git push origin HEAD'
alias gr='git rev-parse --show-toplevel' # git root
alias gs='git status'
alias gt='git tag'
alias gu='git pull' # gu = git update

# Prompt
# Store `tput` colors for future use to reduce fork+exec
# the array will be 0-255 for colors, 256 will be sgr0
# and 257 will be bold
COLOR256=()
COLOR256[0]=$(tput setaf 1)
COLOR256[256]=$(tput sgr0)
COLOR256[257]=$(tput bold)

# Colors for use in PS1 that may or may not change when
# set_prompt_colors is run
PROMPT_COLORS=()

# Change the prompt colors to a theme, themes are 0-29
set_prompt_colors() {
	local h=${1:-0}
	local color=
	local i=0
	local j=0
	for i in {22..231}; do
		((i % 30 == h)) || continue

		color=${COLOR256[$i]}
		# cache the tput colors
		if [[ -z $color ]]; then
			COLOR256[$i]=$(tput setaf "$i")
			color=${COLOR256[$i]}
		fi
		PROMPT_COLORS[$j]=$color
		((j++))
	done
}

PS1='$(ret=$?;(($ret!=0)) && echo "\[${COLOR256[0]}\]($ret) \[${COLOR256[256]}\]")'\
'\[${PROMPT_COLORS[0]}\]\[${COLOR256[257]}\]$(((UID==0)) && echo "\[${COLOR256[0]}\]")\u\[${COLOR256[256]}\] '\
'- \[${PROMPT_COLORS[3]}\]\h\[${PROMPT_COLORS[4]}\] '\
'\[${PROMPT_COLORS[2]}\]\[${PROMPT_COLORS[2]}\]'"$(uname | tr '[:upper:]' '[:lower:]')"'\[${PROMPT_COLORS[2]}\] '\
'\[${PROMPT_COLORS[5]}\]\w '\
'$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "\[${PROMPT_COLORS[2]}\](\[${PROMPT_COLORS[3]}\]git:$branch\[${PROMPT_COLORS[2]}\]) ")'\
'\[${PROMPT_COLORS[0]}\]\$\[${COLOR256[256]}\] '

# set the theme
set_prompt_colors 3

# Enable color support of ls
if ls --color=auto &>/dev/null; then
	alias ls='ls -p --color=auto'
else
	alias ls='ls -p -G'
fi

# Like zlogin(1) except takes a Joyent machine alias
alogin() {
	zlogin "$(vmadm list -o uuid -H alias="$1")"
}

# print a colorized diff
colordiff() {
	local red=$(tput setaf 1 2>/dev/null)
	local green=$(tput setaf 2 2>/dev/null)
	local cyan=$(tput setaf 6 2>/dev/null)
	local reset=$(tput sgr0 2>/dev/null)
	diff -u "$@" | awk "
	/^\-/ {
		printf(\"%s\", \"$red\");
	}
	/^\+/ {
		printf(\"%s\", \"$green\");
	}
	/^@/ {
		printf(\"%s\", \"$cyan\");
	}

	{
		print \$0 \"$reset\";
	}"
	return "${PIPESTATUS[0]}"
}

# Print all supported colors with raw ansi escape codes
colors() {
	local i
	for i in {0..255}; do
		printf "\x1b[38;5;${i}mcolor %d\n" "$i"
	done
	tput sgr0
}

# Convert epoch to human readable
epoch() {
	local num=${1//[^0-9]/}
	(( ${#num} < 13 )) && num=${num}000
	node -pe "new Date($num);"
}

# geoip from shaggly-rl
geoip() {
	curl -s "http://api.hostip.info/get_html.php?ip=$1&position=true"
}

# Platform-independent interfaces
interfaces() {
	node <<-EOF
	var os = require('os');
	var i = os.networkInterfaces();
	Object.keys(i).forEach(function(name) {
		var ip4 = null;
		i[name].forEach(function(int) {
			if (int.family === 'IPv4') {
				console.log('%s: %s', name, int.address);
				return;
			}
		});
	});
	EOF
}

# Calculate CPU load / Core Count
load() {
	node -p <<-EOF
	var os = require('os');
	var c = os.cpus().length;
	os.loadavg().map(function(l) {
		return (l/c).toFixed(2);
	}).join(' ');
	EOF
}

# Total the billable amount in Manta
mbillable() {
	mget -q ~~/reports/usage/storage/latest |\
	json storage | json public.bytes stor.bytes reports.bytes jobs.bytes |\
	awk '
	{
		s += $1;
	}
	END {
		billable = (s / 1024 / 1024 / 1024) + 1;
		human = s;
		units = "B";
		if (s > 1024 * 1024 * 1024 * 1024) {
			human = s / 1024 / 1024 / 1024 / 1024;
			units = "TB";
		} else if (s > 1024 * 1024 * 1024) {
			human = s / 1024 / 1024 / 1024;
			units = "GB";
		} else if (s > 1024 * 1024) {
			human = s / 1024 / 1024;
			units = "MB";
		} else if (s > 1024) {
			human = s / 1024;
			units = "KB";
		}
		printf("%s => using %d %s (%d GB billable)\n",
		ENVIRON["MANTA_USER"], human, units, billable);
	}
	'
}

# Paste bin using manta, requires `mmkdir ~~/public/pastes`
mpaste() {
	local mfile=~~/public/pastes/$(date +%s).html
	pygmentize -f html -O full "$@" | mput "$mfile"
	echo "$MANTA_URL/$MANTA_USER/${mfile#~~/}"
}

# Platform-independent memory usage
meminfo() {
	node <<-EOF
	var os = require('os');
	var free = os.freemem();
	var total = os.totalmem();
	var used = total - free;
	console.log('memory: %dmb / %dmb (%d%%)',
	    Math.round(used / 1024 / 1024),
	    Math.round(total / 1024 / 1024),
	    Math.round(used * 100 / total));
	EOF
}

# Turn a Joyent machine alias into the zonename
ualias() {
	vmadm list -o uuid -H alias="$1"
}

# Follow redirects to untiny a tiny url
untiny() {
	local location=$1 last_location=
	while [[ -n $location ]]; do
		[[ -n $last_location ]] && echo " -> $last_location"
		last_location=$location
		read -r _ location < \
		    <(curl -sI "$location" | grep 'Location: ' | tr -d '[:cntrl:]')
	done
	echo "$last_location"
}

# Undo github flavor markdown
ungithubmd() {
	awk '/^```/ { flag=!flag; $0 = "" } { if (flag) print "    " $0; else print $0; }'
}

# parse URL's to JSON for easy screen scraping on the shell
urlparse() {
	node -e "
	var fs = require('fs');
	var url = require('url');
	var stdin = fs.readFileSync('/dev/stdin').toString();
	console.log(JSON.stringify(url.parse(stdin, true), null, 2));
	"
}

# Load external files
. ~/.bash_aliases    2>/dev/null || true
. ~/.bashrc.local    2>/dev/null || true

# load completion
. /etc/bash/bash_completion 2>/dev/null ||
	. ~/.bash_completion 2>/dev/null

true

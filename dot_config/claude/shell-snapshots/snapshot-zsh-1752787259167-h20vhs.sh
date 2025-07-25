# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
compinit () {
	# undefined
	builtin autoload -XUz
}
ensure_zcompiled () {
	local compiled="$1.zwc" 
	if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]
	then
		echo "Compiling $1"
		zcompile $1
	fi
}
source () {
	ensure_zcompiled $1
	builtin source $1
}
zsh-defer () {
	emulate -L zsh -o extended_glob
	local all=12dmszpr 
	local -i delay OPTIND
	local opts=$all cmd opt OPTARG match mbegin mend 
	while getopts ":hc:t:a$all" opt
	do
		case $opt in
			(*h) print -r -- 'zsh-defer [{+|-}'$all'] [-t delay] word...
zsh-defer [{+|-}'$all'] [-t delay] -c list

Queues up the specified command for deferred execution. Whenever zle is idle,
the next command is popped from the queue. If the command has been queued up
with `-t delay`, execution of the command and all deferred commands after it is
delayed by the specified number of seconds (non-negative real number) without
blocking zle. After that the command is executed either as `word...` with every
word quoted, or, if `-c` is specified, as `eval list`. Commands are executed in
the same order they are queued up.

Options can be used to enable (`+x`) or disable (`-x`) extra actions taken
during and after the execution of the command. By default, all actions are
enabled. The same option can be enabled or disabled more than once -- the last
instance wins.

  Option | Action
  ------ |-------------------------------------------------------
       1 | Redirect standard output to `/dev/null`.
       2 | Redirect standard error to `/dev/null`.
       d | Call `chpwd` hooks.
       m | Call `precmd` hooks.
       s | Invalidate suggestions from zsh-autosuggestions.
       z | Invalidate highlighting from zsh-syntax-highlighting.
       p | Call `zle reset-prompt`.
       r | Call `zle -R`.
       a | Shorthand for all options: `12dmszpr`.

Example `~/.zshrc`:

  source ~/zsh-defer/zsh-defer.plugin.zsh

  PS1="%F{12}%~%f "
  RPS1="%F{240}loading%f"
  setopt prompt_subst

  zsh-defer source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
  zsh-defer source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  zsh-defer source ~/.nvm/nvm.sh
  zsh-defer -c '\''RPS1="%F{2}\$(git rev-parse --abbrev-ref HEAD 2>/dev/null)%f"'\''

Full documentation at: <https://github.com/romkatv/zsh-defer>.'
				return 0 ;;
			(c) if [[ $opts == *c* ]]
				then
					print -r -- "zsh-defer: duplicate option: -c" >&2
					return 1
				fi
				opts+=c 
				cmd=$OPTARG  ;;
			(t) if [[ $OPTARG != (|+)<->(|.<->)(|[eE](|-|+)<->) ]]
				then
					print -r -- "zsh-defer: invalid -t argument: $OPTARG" >&2
					return 1
				fi
				zmodload zsh/mathfunc
				delay='ceil(100 * OPTARG)'  ;;
			(+c | +t) print -r -- "zsh-defer: invalid option: $opt" >&2
				return 1 ;;
			(\?) print -r -- "zsh-defer: invalid option: $OPTARG" >&2
				return 1 ;;
			(:) print -r -- "zsh-defer: missing required argument: $OPTARG" >&2
				return 1 ;;
			(a) [[ $opts == *c* ]] && opts=c  || opts=  ;;
			(+a) [[ $opts == *c* ]] && opts=c$all  || opts=$all  ;;
			(?) [[ $opts == (#b)(*)$opt(*) ]] && opts=$match[1]$match[2]  ;;
			(+?) [[ $opts != *${opt:1}* ]] && opts+=${opt:1}  ;;
		esac
	done
	if [[ $opts != *c* ]]
	then
		cmd="${(@q)@[OPTIND,-1]}" 
	elif (( OPTIND <= ARGC ))
	then
		print -r -- "zsh-defer: unexpected positional argument: ${*[OPTIND]}" >&2
		return 1
	fi
	[[ $opts == *p* && $+RPS1 == 0 ]] && RPS1= 
	(( $#_zsh_defer_tasks )) || _zsh-defer-schedule 0
	_zsh_defer_tasks+="$delay $opts $cmd" 
}
zsh-defer-reset-autosuggestions_ () {
	unsetopt warn_nested_var
	orig_buffer= 
	orig_postdisplay= 
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Users/okash1n/.local/share/aquaproj-aqua/bin\:/opt/homebrew/bin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/Library/Apple/usr/bin\:/Users/okash1n/.local/share/aquaproj-aqua/bin\:/opt/homebrew/bin\:/Applications/Ghostty.app/Contents/MacOS

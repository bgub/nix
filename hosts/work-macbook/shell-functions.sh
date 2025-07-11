# shell functions

# quick navigation to project root (finds git repo root)
function cdroot() {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null)
	if [ $? -eq 0 ]; then
		cd "$root"
	else
		echo "Not in a git repository"
		return 1
	fi
}

# next.js development utilities
# created by https://github.com/lubieowoce

function next-dev {
	local dir="$1"

	if [ -n "$dir" ]; then
		local switch_re="^--?[a-zA-Z0-9_]+$"
		if [[ "$dir" =~ $switch_re ]]; then
			# we have a switch in first place, don't treat it as a directory
			dir=
		else
			# we'll forward the rest of the arguments, so remove the directory from them
			shift
		fi
	fi

	if [ -z "$dir" ]; then
		for ext in js mjs ts; do
			if [[ -f "$PWD/next.config.$ext" ]]; then
				echo "next-dev: no directory specified, defaulting to current directory" >&2
				dir="$PWD"
				break
			fi
		done
	fi

	if [ -z "$dir" ]; then
		echo "usage: next-dev <dir> [...args]" >&2
		return 1
	fi

	if ! [ -d "$dir" ]; then
		echo "next-dev: $dir is not a directory" >&2
		return 1
	fi

	[ -d "$dir/.next" ] && rm -rf "$dir/.next"
	pnpm exec next dev "$dir" "$@"
}

function next-dev-turbo {
	local dir="$1"
	shift
	next-dev "$dir" --turbo "$@"
}

function next-build-and-start {
	local dir="$1"

	if [ -n "$dir" ]; then
		local switch_re="^--?[a-zA-Z0-9_]+$"
		if [[ "$dir" =~ $switch_re ]]; then
			# we have a switch in first place, don't treat it as a directory
			dir=
		else
			# we'll forward the rest of the arguments, so remove the directory from them
			shift
		fi
	fi

	if [ -z "$dir" ]; then
		for ext in js mjs ts; do
			if [[ -f "$PWD/next.config.$ext" ]]; then
				echo "next-build-and-start: no directory specified, defaulting to current directory" >&2
				dir="$PWD"
				break
			fi
		done
	fi

	if [ -z "$dir" ]; then
		echo "usage: next-build-and-start <dir> [...args]" >&2
		echo "       <dir> can be omitted" >&2
		return 1
	fi

	if ! [ -d "$dir" ]; then
		echo "next-build-and-start: $dir is not a directory" >&2
		return 1
	fi

	[ -d "$dir/.next" ] && rm -rf "$dir/.next"
	pnpm next build "$dir" "$@" && pnpm next start "$dir"
}

# adapted from @richyliu with small modifications

# This script syncs agenda.org between my local org folder and my iCloud folder
# for Beorg. Local changes override remote for agenda.org, while remote changes
# override local for inbox.org.
#
# Additionally, this script syncs my done items to a separate file in the Beorg
# iCloud folder.

set -euo pipefail

if [ -d "$HOME/Personal/org" ]; then
    local="$HOME/Personal/org"
    remote="$HOME/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org"
else
    echo "ERROR: no sync directory found"
    exit 1
fi

function get_mod_time() {
    fname="$1"

    # check file exists
    if [ ! -f "$fname" ]; then
        echo 0
    else
        # be careful: use -f %m if you're using the coreutils that ship with macOS.
        stat -c %Y "$fname" 2> /dev/null
    fi
}

function force_sync() {
    if [[ $1 =~ "iCloud" ]] && [[ -f $1 ]]; then
        head -c 1 "$1" > /dev/null
    fi
}

function update_file() {
    from="$1"
    to="$2"
    for f in "$from" "$to"; do force_sync "$f"; done

    # check that $from is newer than $to and that they are different
    if [ "$(get_mod_time "$from")" -gt "$(get_mod_time "$to")" ] && ! cmp -s "$from" "$to"; then
        mkdir -p "$(dirname "$to")"
        cp "$from" "$to"
        echo "Synced from $from to $to"
    fi
}

# sync remote to local first for inbox.org
# check if remote file is newer than local file
if [ "$(get_mod_time "$remote/inbox.org")" -gt "$(get_mod_time "$local/inbox.org")" ]; then
    if ! cmp -s "$remote/inbox.org" "$local/inbox.org"; then
        echo "inbox.org updated from iCloud at $(date "+%H:%M:%S")"
        update_file "$remote/inbox.org" "$local/inbox.org"
    fi
    # remote is newer, but the same, so do nothing
else
    # otherwise, sync local to remote
    update_file "$local/inbox.org" "$remote/inbox.org"
fi

# sync local to remote for all other org files
shopt -s globstar
for f in "$local"/{roam/**,*.org}; do
    if [[ "$(basename "$f")" != "inbox.org" ]]; then
        update_file "$f" "$remote/${f#"$local"/}"
    fi
done

# sync beorg's own files from remote to local
for f in "$remote"/*-beorg.org; do
    update_file "$f" "$local/$(basename "$f")"
done

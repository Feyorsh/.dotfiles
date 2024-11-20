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

function update_file() {
    from="$1"
    to="$2"

    # check that $from is newer than $to and that they are different
    if [ "$(get_mod_time "$from")" -gt "$(get_mod_time "$to")" ] && ! cmp -s "$from" "$to"; then
        cp "$from" "$to"
        echo "Synced from $from to $to"
    fi
}

# always sync agenda to remote
update_file "$local/agenda.org" "$remote/agenda.org"

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

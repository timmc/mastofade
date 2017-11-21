#!/bin/bash
# Fade your Mastodon avatar from one image to another. Call from a
# cron job to set the fade rate.
#
# Requirements:
# - imagemagick installed (calls `composite`)
# - OAuth application with write permissions registered in account
#   (see Development tab in Mastodon settings)
#
# Usage:
# $0 <config-file>
#
# Config file is a shell script that is expected to set the following
# variables:
#
# MF_SERVER - instance domain e.g. botsin.space
# MF_USER_ID - either numeric ID or username on instance (just used for
#   tmpfile management)
# MF_OLD_AVATAR - CWD-relative path to initial avatar image
# MF_NEW_AVATAR - CWD-relative path to final avatar image
# MF_TOKEN - Access token with write permissions to account

set -eu -o pipefail

. "$1"

# User ID is just to avoid collisions in tmp dir; can take either
# username or numeric ID
tmp_base="/tmp/mastofade-${MF_SERVER}_${MF_USER_ID}"
state_file="$tmp_base-state.log"

if [[ -e "$state_file" ]]; then
    last_percent=`cat -- "$state_file"`
else
    last_percent=0
fi

if [[ "$last_percent" -ge 100 ]]; then
    echo "Already reached 100%"
    exit
fi

cur_percent=$((last_percent + 1))
# Can't set image if name hasn't changed:
# https://github.com/tootsuite/mastodon/issues/3804
# https://github.com/tootsuite/mastodon/issues/5776
outfile="$tmp_base-out-${cur_percent}.png"

echo "Writing $cur_percent% progress image to $outfile"
composite -dissolve "$cur_percent" "$MF_NEW_AVATAR" "$MF_OLD_AVATAR" "$outfile"

echo "Uploading avatar"
cexit=$(curl -sS -m 30 -H "Authorization: Bearer $MF_TOKEN" -X PATCH \
             -F "avatar=@$outfile" -o /dev/null -w '%{http_code}' \
             -- "https://$MF_SERVER/api/v1/accounts/update_credentials")

if [[ "$cexit" = "200" ]]; then
    echo "Uploaded"
else
    echo "Failure: Exit code $cexit"
fi

echo "Cleaning up"
rm -- "$outfile"
echo "$cur_percent" > "$state_file"

#!/usr/bin/env bash

RC=1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function cleanup() {
    cp -f "bug_01.v" "$DIR/bug.v" || RC=$?
    if [ -f "$DIR/bug.v" ]; then
        touch "$DIR/build.log" "$DIR/bug.log"
        bash "$DIR/reply-coqbot.sh" "$(cat coqbot-request-stamp)" "$FILE" "$DIR/bug.v" "$DIR/build.log" "$DIR/bug.log"
    else
        touch "$DIR/build.log"
        bash "$DIR/reply-coqbot-error.sh" "$(cat coqbot-request-stamp)" "$FILE" "$DIR/build.log"
    fi
    exit $RC
}

trap cleanup SIGINT SIGKILL EXIT

set -x

source "$DIR/coqbot.sh" 2>"$DIR/log"

cat "$DIR/build.log"

FILE="$(tac "$DIR/build.log" | grep --max-count=1 -A 1 '^Error' | grep '^File "[^"]*", line [0-9]*, characters [0-9-]*:' | grep -o '^File "[^"]*' | sed 's/^File "//g')"

(yes "y" || true) | find-bug.py "$FILE" bug_01.v tmp.v --inline-user-contrib -l - "$DIR/bug.log" && RC=0
cleanup

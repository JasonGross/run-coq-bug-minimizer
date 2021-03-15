#!/usr/bin/env bash
# USAGE: $0 ID FILENAME ERROR_LOG_FILENAME

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. "$DIR/coqbot-config.sh"

id="$1"
comment_contents="Error: Could not minimize file $2"
comment_contents+="${nl}<details><summary>error log</summary>${nl}${nl}${start_code}$(cat "$3")${end_code}${nl}</details>"
comment_contents+="${nl}${nl}$(cat "$DIR/feedback.md")"

file="$(mktemp)"
cat > "$file" <<EOF
${id}${nl}${comment_contents}
EOF

if [ ! -z "${COQBOT_URL}" ]; then
    curl -X POST --data-binary "@${file}"
else
    echo curl -X POST --data-binary "@${file}" "${COQBOT_URL}"
    echo cat "$file"
    cat "$file"
fi

rm "$file"

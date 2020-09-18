#!/usr/bin/env bash
SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -f $SCRIPT_ROOT/../README.md
rm -f $SCRIPT_ROOT/../.gitignore
rm -f $SCRIPT_ROOT/../include/note.txt
rm -f $SCRIPT_ROOT/../src/note.txt
#!/usr/bin/env powershell

rm $PSScriptRoot/../README.md  -ErrorAction SilentlyContinue
rm $PSScriptRoot/../.gitignore  -ErrorAction SilentlyContinue
rm $PSScriptRoot/../include/note.txt  -ErrorAction SilentlyContinue
rm $PSScriptRoot/../src/note.txt  -ErrorAction SilentlyContinue

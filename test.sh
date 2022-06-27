#!/bin/bash

set -x

reset() { rm -rfv creator/artifact && earthly prune --reset --all ; }
check() { [ -e "creator/artifact" ] && echo "local file exists" || echo "local file doesn't exist" ; }

run() {
    local suffix=$1
    echo "SUFFIX $suffix"

    echo "test case #1. run creator+create directly and then consumer+consume. local file should be created and used."
    reset
    earthly ./creator+create"$suffix"
    check
    earthly ./consumer+consume"$suffix"
    [ $? = "1" ] && echo "TEST CASE #1 FAILED" || echo "TEST CASE #1 PASSED"
    reset

    echo "test case #2, run consumer+consume twice. local file should be created one first run and re-used on second run."
    earthly ./consumer+consume"$suffix"
    [ $? = "1" ] && echo "TEST CASE #2.1 FAILED" || echo "TEST CASE #2.1 PASSED"
    echo "skip reset and re-run"
    earthly ./consumer+consume"$suffix"
    [ $? = "1" ] && echo "TEST CASE #2.2 FAILED" || echo "TEST CASE #2.2 PASSED"
    check
}

run ""
run ".fixed"

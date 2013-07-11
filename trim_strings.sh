#!/bin/bash

trim_string() {
    # trim leading and trailing spaces and tabs from string
    local STR="$1"
    STR="${STR##*([[:space:]])}" # remove leading spaces
    STR="${STR%%*([[:space:]])}" # remove trailing spaces
    echo "$STR"
}

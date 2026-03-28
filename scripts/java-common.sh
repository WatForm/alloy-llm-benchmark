#!/bin/bash

# Shared Java helpers for scripts in this repository.

java_major_version() {
    local java_bin="$1"
    "$java_bin" -version 2>&1 | awk -F '[\".]' '/version/ { if ($2 == "1") print $3; else print $2; exit }'
}

is_java_version() {
    local java_bin="$1"
    local expected_major="$2"
    local detected

    [ -x "$java_bin" ] || return 1
    detected=$(java_major_version "$java_bin")
    [ "$detected" = "$expected_major" ]
}

require_java_for_version() {
    local major="$1"
    local tool_name="$2"
    local env_name="JAVA_HOME_${major}"
    local env_home="${!env_name}"
    local java_bin=""

    if [ -z "$env_home" ]; then
        echo "Error: ${env_name} is required for ${tool_name}." >&2
        echo "Set it in your shell before running this script." >&2
        echo "Example: export ${env_name}=\"/path/to/jdk-${major}\"" >&2
        return 1
    fi

    java_bin="$env_home/bin/java"
    if [ ! -x "$java_bin" ]; then
        echo "Error: ${env_name} does not point to a valid Java binary: $java_bin" >&2
        return 1
    fi

    if ! is_java_version "$java_bin" "$major"; then
        echo "Error: Java ${major} is required for ${tool_name}." >&2
        echo "Current ${env_name}: $env_home" >&2
        echo "This resolves to Java $(java_major_version "$java_bin"), expected Java ${major}." >&2
        return 1
    fi

    echo "$java_bin"
}

resolve_alloy_tmpdir() {
    if [ -n "$ALLOY_TMPDIR" ]; then
        echo "$ALLOY_TMPDIR"
    elif [ -n "$TMPDIR" ]; then
        echo "${TMPDIR%/}/alloy-benchmark"
    else
        echo "/tmp/alloy-benchmark"
    fi
}

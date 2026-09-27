#!/usr/bin/env bash

set -u

usage() {
    echo "Usage: $0 DIRECTORY ERROR|WARN [--top N]"
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

directory="$1"
level="$2"
top=""

if [[ ! -d "$directory" ]]; then
    echo "Error: directory does not exist: $directory" >&2
    exit 1
fi

if [[ "$level" != "ERROR" && "$level" != "WARN" ]]; then
    echo "Error: level must be ERROR or WARN" >&2
    usage
    exit 1
fi

shift 2

while [[ $# -gt 0 ]]; do
    case "$1" in
        --top)
            if [[ $# -lt 2 ]]; then
                echo "Error: --top requires a number" >&2
                exit 1
            fi

            top="$2"

            if [[ ! "$top" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: N must be a positive integer" >&2
                exit 1
            fi

            shift 2
            ;;
        *)
            echo "Error: unknown argument: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$top" ]]; then
    echo "Module | Messages"
    echo "----------------"
else
    echo "Module | Messages (Top $top)"
    echo "---------------------------"
fi

find "$directory" -type f -name "*.log" -print0 |
while IFS= read -r -d '' file; do
    awk -v target="$level" '
        $3 == target {
            module = $4
            sub(/:$/, "", module)
            count[module]++
        }
        END {
            for (module in count) {
                print module, count[module]
            }
        }
    ' "$file"
done |
awk '
    NF == 2 {
        total[$1] += $2
    }
    END {
        for (module in total) {
            print module, total[module]
        }
    }
' |
sort -k2,2nr -k1,1 |
{
    if [[ -n "$top" ]]; then
        head -n "$top"
    else
        cat
    fi
} |
awk '{
    printf "%-15s | %s\n", $1, $2
}'


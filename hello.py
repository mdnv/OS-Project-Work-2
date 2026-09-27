#!/usr/bin/env python3

import sys
from pathlib import Path

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} FILE")
    sys.exit(1)

file_path = Path(sys.argv[1])

try:
    with file_path.open("rb") as file:
        content = file.read()

    print(f"File: {file_path}")
    print(f"Size: {len(content)} bytes")

except FileNotFoundError:
    print(f"Error: file not found: {file_path}", file=sys.stderr)
    sys.exit(1)

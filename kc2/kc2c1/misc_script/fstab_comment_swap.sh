#!/usr/bin/gawk -f

# For lines that don't start with #, if field 3 is swap
# print whole line starting with #
/^[^#]/ {
    if ($3 == "swap") {
        printf "#%s\n", $0
    }
}


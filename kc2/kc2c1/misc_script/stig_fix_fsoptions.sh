#!/usr/bin/gawk -f

# V-230300 - RHEL 8 must prevent files with the setuid and setgid bit set from being executed on the /boot directory.
# V-230301 - RHEL 8 must prevent special devices on non-root local partitions.
/^.+[[:space:]]+\/boot/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid")
    printf (line "\n")
    next
}

# V-230511 - RHEL 8 must mount /tmp with the nodev option.
# V-230512 - RHEL 8 must mount /tmp with the nosuid option.
# V-230513 - RHEL 8 must mount /tmp with the noexec option.
#   noexec not added
#   Software frequently copies stuff to /tmp and executes it.
/^.+[[:space:]]+\/tmp/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid")
    printf (line "\n")
    next
}

# V-230514 - RHEL 8 must mount /var/log with the nodev option.
# V-230515 - RHEL 8 must mount /var/log with the nosuid option.
# V-230516 - RHEL 8 must mount /var/log with the noexec option.
/^.+[[:space:]]+\/var\/log/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid,noexec")
    printf (line "\n")
    next
}

# V-230520 - RHEL 8 must mount /var/tmp with the nodev option.
# V-230521 - RHEL 8 must mount /var/tmp with the nosuid option.
# V-230522 - RHEL 8 must mount /var/tmp with the noexec option.
/^.+[[:space:]]+\/var\/tmp/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid,noexec")
    printf (line "\n")
    next
}

# V-230301 - RHEL 8 must prevent special devices on non-root local partitions.
# V-230302 - RHEL 8 must prevent code from being executed on file systems that contain user home directories.
/^.+[[:space:]]+\/home/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid,noexec")
    printf (line "\n")
    next
}

/^.+[[:space:]]+\/opt/ {
    line = replace_mntopt($0, "defaults,nodev")
    printf (line "\n")
    next
}

/^.+[[:space:]]+\/var/ {
    line = replace_mntopt($0, "defaults,nodev")
    printf (line "\n")
    next
}

# V-230517 - RHEL 8 must mount /var/log/audit with the nodev option.
# V-230518 - RHEL 8 must mount /var/log/audit with the nosuid option.
# V-230519 - RHEL 8 must mount /var/log/audit with the noexec option.
/^.+[[:space:]]+\/dev\/mapper\/vg_root-lv_var_log_audit/ {
    line = replace_mntopt($0, "defaults,nodev,nosuid,noexec")
    printf (line "\n")
    next
}

# UUID
# /boot, UEFI, and swap use this format
# STIG doesn't use mount options on these
/UUID=/ { print $0; next }

# Any other lines
{
    print $0
}

# Filesystem option function
function replace_mntopt(fsline, options) {
    n=split(fsline,field," ",sep)
    field[4] = options
    line=""
    for(i=1; i<=n; i++)
        line=(line field[i] sep[i])
    return line
}

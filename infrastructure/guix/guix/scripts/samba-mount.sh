#!/bin/sh

mkdir -p mnt

guix shell cifs-utils \
    -- sh -c "sudo \$GUIX_ENVIRONMENT/sbin/mount.cifs //127.0.0.1/ mnt -o port=4445,uid=$(id -u),gid=$(id -g)"

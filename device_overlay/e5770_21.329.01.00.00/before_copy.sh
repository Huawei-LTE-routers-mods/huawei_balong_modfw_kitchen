#!/bin/bash

if [[ -d "$WORKDIR/app/" ]];
then
    # Rename some binaries in /app/bin/
    mv "$WORKDIR/app/bin/npdaemon" "$WORKDIR/app/bin/npdaemon.orig"
fi

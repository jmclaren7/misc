#!/bin/bash

onexit() {
	echo "Exiting" >&2
	jobs -p | xargs kill
	restic unlock
}
trap onexit INT TERM

source ./restic-config.sh

restic -r $REPOSITORY \
	--verbose \
	backup $SOURCE

restic -r $REPOSITORY \
	--verbose \
	forget \
	--keep-daily $RETENTION_DAYS \
	--keep-weekly $RETENTION_WEEKS \
	--keep-monthly $RETENTION_MONTHS \
	--keep-yearly $RETENTION_YEARS &
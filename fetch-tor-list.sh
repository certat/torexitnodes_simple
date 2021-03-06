#!/bin/bash

path=$(dirname $BASH_SOURCE)

#### Source 
TARGETDIR="$path/data/torproject.org"
set -e
DATESTAMP=`date "+%Y-%m-%d--%H:%M:%S"`
DATESTAMP2=`date "+%Y-%m-%d %H:%M:%S"`
URL="https://check.torproject.org/exit-addresses"
LOGFILE=/var/log/fetch-tor-list.log
WEBTARGETDIR=$path/www/tor/static

if [ ! -d ${TARGETDIR} ]; then
    mkdir -p $TARGETDIR
fi
if [ ! -f $LOGFILE ]; then
    echo "could not find / write to log file '$LOGFILE'. Please touch(1) it first, make it writeable and then re-try"
    exit 255
fi

wget --quiet -4 -O - -o $LOGFILE --no-check-certificate $URL \
     | bzip2 \
     > "$TARGETDIR/$DATESTAMP.bz2"

python3 $path/insert-data.py --torproject-format $TARGETDIR/$DATESTAMP.bz2



##### post-fetching scripts
#### # select the current data and dump it to latest.bz2
psql -tA tordb_simple -c "select ip from node where exit_address_ts >= date(now()) - interval '1 day';"  | \
	sort | uniq > $WEBTARGETDIR/latest ;
bzip2  -f $WEBTARGETDIR/latest




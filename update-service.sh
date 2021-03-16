#!/bin/bash

[[ ! -d "/home/pi/git/planefence-airlinecodes" ]] && git clone https://github.com/kx1t/planefence-airlinecodes /home/pi/git/planefence-airlinecodes
pushd /home/pi/git/planefence-airlinecodes
git pull --all
cp -fu airlinecodes.txt /var/www/php

sed 's/^\([A-Z0-9]\{3\}\).*/\1/g' /var/www/php/airline-missed.txt 2>/dev/null | sort -k1,1 -u | awk NF >/tmp/missed

while read -r missed
do
	grep "^$missed," /var/www/php/airlinecodes.txt 2>&1 >/dev/null || echo "Airline code \"$missed\", examples: $(grep "^$missed" /var/www/php/airline-missed.txt |xargs)" > airlinecodes-unresolved.txt
done < /tmp/missed

# remove dupes:
awk -F',' '!seen[$1]++' airlinecodes-unresolved.txt > /tmp/missed
mv -f /tmp/missed airlinecodes-unresolved.txt
touch airlinecodes-unresolved.txt

# now write it back to the repo:
git add -A *
git commit -m "auto-upload $(date)"
git push

popd

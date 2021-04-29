#!/bin/bash

AIRLINENAMESDIR=~/airlinenames

[[ ! -d ~/git/planefence-airlinecodes ]] && git clone https://github.com/kx1t/planefence-airlinecodes ~/git/planefence-airlinecodes
pushd ~/git/planefence-airlinecodes
git pull --all
cp -fu airlinecodes.txt $AIRLINENAMESDIR

tmpfile=$(mktemp)
tmpfile2=$(mktemp)

sed 's/^\([A-Z0-9]\{3\}\).*/\1/g' $AIRLINENAMESDIR/airline-missed.txt 2>/dev/null | sort -k1,1 -u | awk NF >$tmpfile

while read -r missed
do
	tac $AIRLINENAMESDIR/airline-missed.txt | grep "^$missed," $AIRLINENAMESDIR/airlinecodes.txt 2>&1 >/dev/null || echo "Airline code \"$missed\", examples:$(tac $AIRLINENAMESDIR/airline-missed.txt| grep "^$missed" | xargs)" >> $tmpfile2
done < $tmpfile

# remove dupes:
cat $tmpfile2 airlinecodes-unresolved.txt | awk -F',' '!seen[$1]++' airlinecodes-unresolved.txt > $tmpfile
mv -f $tmpfile airlinecodes-unresolved.txt
touch airlinecodes-unresolved.txt
rm $tmpfile2

# back up the server dir:
pushd $AIRLINENAMESDIR && tar -czvf backup.tgz ./* && popd && mv $AIRLINENAMESDIR/backup.tgz .


# now write it back to the repo:
git add -A *
git commit -m "auto-upload $(date)"
git push

popd

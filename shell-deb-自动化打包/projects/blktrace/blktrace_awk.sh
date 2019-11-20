#!/bin/bash

TMP_DIR=".blktrace_cal"

# extend the blktrace log to "blockid R/W"
extend()
{
    awk -v max=$2 -v mod=$3 '{
        if ( NR%max==mod && $6 == "D" && (index($7, "R") || index($7, "W")) ) {
            for(i=0; i<$10; i++) {
                print $8+i" "substr($7, 1, 1);
            }
        }
    }' $1 | sort -k1 -nr > $TMP_DIR/.tmp.$1.$3
    touch $TMP_DIR/$3.ok
}

usage()
{
    echo "Usage: $1 input_log [parallel_num]"
    exit
}

rm -rf $TMP_DIR
mkdir $TMP_DIR

if [ "$1" == "" ]; then
    usage $0
fi

# does input_log exists?
if [ ! -f $1 ]; then
    echo "($1) not exists"
    exit
fi

parallel=$2

if [ "$2" == "" ]; then
    parallel=4
fi

echo "[input: $1]"

max=`expr $parallel - 1`
files=""
filename=`basename $1`

echo "[run $parallel process]"

for i in `seq 0 $max`
do
    extend $filename $parallel $i &
    files=$files" $TMP_DIR/.tmp.$filename.$i"
done
echo "processing...."

nr=0
# awk will finish if all *.ok created.
while [ $nr -ne "$parallel" ]
do
    nr=`find $TMP_DIR -maxdepth 1 -name "*.ok"|wc -l`
    echo -n "."
    sleep 1
done

echo ""
echo "merge sort"
sort -m -k1 -nr $files | uniq -c | sort -k1 -nr > tmp
total=`awk '{sum+=$1} END{print sum}' tmp`
awk -v sum=$total '{
    print $0"\t"$1*1000/sum;
}' tmp > result

echo "sort finish."

rm -rf $TMP_DIR

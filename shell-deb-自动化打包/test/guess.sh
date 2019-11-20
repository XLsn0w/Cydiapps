#!/bin/bash
#set -x
echo "what num i think you guess"
function random()
{
	min=$1;
	max=$2;
	num=$(date +%S+%N);
	((retnum=num%max+min));
	echo $retnum;
}
answer=$(random 1 100)
guess=0
time=0
while (( $guess != $answer ))
do
	read -p "you guess:" guess
	time=$(($time+1))
#	echo $guess
	if [ $guess -lt $answer ]
	then
		echo "too small"

	else
		echo "too big"
	fi
done
echo "bingo,the num is $answer,you guess $time"

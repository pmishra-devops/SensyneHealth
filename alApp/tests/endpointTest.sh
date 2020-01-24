#!/bin/bash

# set -e
set -x

testpassed=1
for i in {1..32}
do
	test1=$(curl -s $endpoint | grep '<title>Todo App</title>')
	if [[ -n $test1 ]]
	then
		test2=$(curl -s $endpoint | grep 'The server is not ready yet.')
    test3=$(curl -s $endpoint | grep 'navailable')
    test4=$(curl -s $endpoint | grep '502')
		test5=$(curl -s $endpoint | grep 'Server Error')
		if [[ -z $test2 ]] && [[ -z $test3 ]] && [[ -z $test4 ]] && [[ -z $test5 ]]
		then
			echo "Endpoint testing passed."
			testpassed=0
			break
		fi
	fi
	sleep $sleep
done

exit $testpassed

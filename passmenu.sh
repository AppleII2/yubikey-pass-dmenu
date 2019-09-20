#!/bin/bash

# TODO Add handling for usernames using cli argument
# TODO Add more graceful error handling for nonexisting passwords
# TODO Trying incorrect password fools the cached keys check... Fix this

path=$HOME/.password-store
passname=$(ls $path | cut -d '.' -f 1 | dmenu)

if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye | grep 'SERIALNO') ]]
then
	password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg)
	echo "UNLOCKED CARD DETECTED"
else
	echo "NO UNLOCKED CARD DETECTED"
	if [[ ! $(gpg --card-status | grep 'Serial number') ]]
	then
		echo "NO CARD DETECTED AT ALL"
		true | dmenu -p 'Insert smartcard and press enter...'
	fi

	for i in {1..3}
	passcode=$(true | dmenu -p "Input smartcard passcode")
	password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $path/$passname.gpg)
fi

if [[ $password ]]
then
	echo "PASSWORD GOOD, TYPING"
	echo "str" $password | xte
fi

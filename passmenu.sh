#!/bin/bash

# TODO Add handling for usernames using cli argument
# TODO Add more graceful error handling for nonexisting passwords
# TODO Trying incorrect password fools the cached keys check... Fix this

path=$HOME/.password-store
passname=$(ls $path | cut -d '.' -f 1 | dmenu)


function main {
if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye | grep 'SERIALNO') ]]
then
	decrypt_cached 
	echo "UNLOCKED CARD DETECTED"
	if [[ $password ]]
	then
		echo "PASSWORD GOOD, TYPING"
		type_password $password
		return 1
	fi
fi
unlock_questions
decrypt_nocache $passcode
if [[ $password ]]
then
	echo "PASSWORD GOOD, TYPING"
	type_password $password
	return 1
fi
}

function decrypt_cached {
	echo "UNLOCKED CARD DETECTED"
	password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg)
}

function decrypt_nocache {
	password=$(gpg --batch --pinentry-mode loopback --passphrase $1 -d $path/$passname.gpg)
}

function unlock_questions {
	echo "NO UNLOCKED CARD DETECTED"
	if [[ ! $(gpg --card-status | grep 'Serial number') ]]
	then
		echo "NO CARD DETECTED AT ALL"
		true | dmenu -p 'Insert smartcard and press enter...'
	fi
	passcode=$(true | dmenu -p "Input smartcard passcode")
	echo "PASSCODE" $passcode
	return 1
}

function type_password {
	echo "str" $1 | xte
	return 1
}

main

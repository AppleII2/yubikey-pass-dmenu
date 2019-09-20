#!/bin/bash

# TODO Add handling for usernames using cli argument

path=$HOME/.password-store
passname=$(ls $path | cut -d '.' -f 1 | dmenu)

function main {
if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye | grep 'SERIALNO') ]]
then
	password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg)
	if [[ $password ]]
	then
		type_password $password
		return 1
	fi
fi
unlock_questions
password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $path/$passname.gpg)
if [[ $password ]]
then
	type_password $password
	return 1
fi
}

function unlock_questions {
	if [[ ! $(gpg --card-status | grep 'Serial number') ]]
	then
		true | dmenu -p 'Insert smartcard and press enter...'
	fi
	passcode=$(true | dmenu -p "Input smartcard passcode")
	return 1
}

function type_password {
	echo "str" $1 | xte
	return 1
}

main

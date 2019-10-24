#!/bin/bash

req_field=${1-1} # Line of password file to type
path=$HOME/.password-store # Location of password store file
passname=$(ls $path | cut -d '.' -f 1 | dmenu)
[[ -n $passname ]] || exit

function main {
# If card present + unlocked or has had incorrect PIN tried
if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye | grep 'SERIALNO') ]]
then
	password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg | cut -d$'\n' -f $req_field)
	if [[ $password ]]
	then
		type_password $password
		return
	fi
fi
unlock_questions
password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $path/$passname.gpg | cut -d$'\n' -f $req_field)
if [[ $password ]]
then
	type_password $password
fi
}

function unlock_questions {
	# If card not inserted at all
	if [[ ! $(gpg --card-status | grep 'Serial number') ]]
	then
		true | dmenu -p 'Insert smartcard and press enter...'
		if [[ ! $(gpg --card-status | grep 'Serial number') ]]
		then
			exit
		fi
	fi
	passcode=$(true | dmenu -p "Input smartcard passcode")
}

function type_password {
	echo "str" $1 | xte
}

main

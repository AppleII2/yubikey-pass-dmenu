#!/bin/bash

if [[ $1 == "--line" ]]; then
	req_field=$2
	shift 2
else
	req_field=1
fi

path=$HOME/.password-store # Location of password store file

prefix=${PASSWORD_STORE_DIR-~/.password-store}

passname=$(find $prefix -name '*.gpg' -printf '%f\n' | sed 's/\.gpg$//1' | dmenu)
passpath=$(find $prefix -name $passname.gpg)
[[ -n $passpath ]] || exit

function get_pass {

# If card present + unlocked or has had incorrect PIN tried
if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye) ]]
then
	# Try to get password without providing a passcode
	password=$(gpg --batch --pinentry-mode loopback -d $passpath | cut -d$'\n' -f $req_field)
	[[ -z $password ]] || return
fi
# Prompt for smartcard if needed + get pin
[[ $(gpg --card-status) ]] || true | dmenu -p 'Insert smartcard and press enter...'
[[ $(gpg --card-status) ]] || exit
passcode=$(true | dmenu -p "Input smartcard PIN...")
# Try to get password with provided PIN 
password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $passpath | cut -d$'\n' -f $req_field)
}

get_pass
[[ -n $password ]] || exit
xdotool type --clearmodifiers $password 

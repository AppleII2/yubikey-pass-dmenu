#!/bin/bash

req_field=${1-1} # Line of password file to type
path=$HOME/.password-store # Location of password store file
passname=$(ls $path | cut -d '.' -f 1 | dmenu)
[[ -n $passname ]] || exit

function get_pass {
# If card present + unlocked or has had incorrect PIN tried
if [[ $(gpg-connect-agent 'scd getinfo card_list' /bye) ]]
then
	# Try to get password without providing a passcode
	password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg | cut -d$'\n' -f $req_field)
	[[ -z $password ]] || return
fi
# Prompt for smartcard if needed + get pin
[[ $(gpg --card-status) ]] || true | dmenu -p 'Insert smartcard and press enter...'
[[ $(gpg --card-status) ]] || exit
passcode=$(true | dmenu -p "Input smartcard PIN...")
# Try to get password with provided PIN 
password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $path/$passname.gpg | cut -d$'\n' -f $req_field)
}

get_pass
[[ -n $password ]] || exit
xdotool type --clearmodifiers $password 

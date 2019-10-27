#!/bin/bash

if [[ $1 == "--username" ]]; then
	req_field=2
	shift
else
	req_field=1
fi

echo $req_field

path=$HOME/.password-store # Location of password store file

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

passname=$(printf '%s\n' "${password_files[@]}" | dmenu "$@")

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

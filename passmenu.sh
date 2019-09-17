#!/bin/bash

path=$HOME/.password-store
passname=$(ls $path | cut -d "." -f 1 | dmenu)

while true ; do
	if [ ! $passcode ]
	then
		password=$(gpg --batch --pinentry-mode loopback -d $path/$passname.gpg 2> /tmp/passman-stderror)
	else
		password=$(gpg --batch --pinentry-mode loopback --passphrase $passcode -d $path/$passname.gpg 2> /tmp/passman-stderror)
	fi
	error=$(</tmp/passman-stderror)
	echo $error
	if [[ $error =~ "decryption failed" ]]
	then
		if [[ $error =~ "Card not present" ]]
		then
			echo "CARD NOT PRESENT"
			true | dmenu -p "Insert smartcard and press enter..."
		else
			echo $error
		fi
	elif [[ $error =~ "Sorry, we are in batchmode" ]]
		then
			passcode=$(true | dmenu -p "Input passcode")
	else
	       echo "str" $password | xte
	       rm /tmp/passman-stderror
	       break
	fi
done

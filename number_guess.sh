#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RND=$(( (RANDOM % 1000 ) + 1 ))
# echo My secret number is $RND.

echo Enter your username:
read INPUT_USERNAME

USER_QUERY=$($PSQL "SELECT * FROM players WHERE username='$INPUT_USERNAME'")
if [[ -z $USER_QUERY ]]
then
	# new user
	echo Welcome, $INPUT_USERNAME! It looks like this is your first time here.
	USERNAME=$INPUT_USERNAME
	GAMES_PLAYED=0
	BEST_GAME=1000
	INSERT_NEW_USER=$($PSQL "INSERT INTO players VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME)")
else
	# returning user
	USERNAME=$(echo $USER_QUERY | cut -f1 -d"|")
	GAMES_PLAYED=$(echo $USER_QUERY | cut -f2 -d"|")
	BEST_GAME=$(echo $USER_QUERY | cut -f3 -d"|")
	echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

echo Guess the secret number between 1 and 1000:

GUESSES=0
IS_CORRECT=1
until [[ $IS_CORRECT = 0 ]]
do
	IS_VALID_GUESS=1
	until [[ $IS_VALID_GUESS = 0 ]]
	do
		read GUESS
		if [[ $GUESS =~ ^[0-9]+$ ]]
		then
			IS_VALID_GUESS=0
		else
			echo That is not an integer, guess again:
		fi
	done

	GUESSES=$(( GUESSES + 1 ))

	if (( $GUESS < $RND ))
	then
		# if lower
		echo "It's higher than that, guess again:"
	elif (( $GUESS > $RND ))
	then
		# if higher
		echo "It's lower than that, guess again:"
	else
		# is correct
		echo "You guessed it in $GUESSES tries. The secret number was $RND. Nice job!"
		IS_CORRECT=0
	fi
done

GAMES_PLAYED=$(( GAMES_PLAYED + 1))

if (( $GUESSES < $BEST_GAME ))
then
	BEST_GAME=$GUESSES
fi

INSERT_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")


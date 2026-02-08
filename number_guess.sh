#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE name='$USER_NAME'")
  BEST_GAME=$($PSQL "SELECT MIN(score) FROM users INNER JOIN games USING(user_id) WHERE name='$USER_NAME'")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
RANDOM_NUMBER=$(( 1 + $RANDOM % 1000 ))
COUNTER=0
while
  read n
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  if [[ ! $n =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $n > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $n < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  fi
  [[ $n != $RANDOM_NUMBER ]]
do true; done

GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, score) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

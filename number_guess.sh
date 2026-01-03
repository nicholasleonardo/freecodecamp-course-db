#!/bin/bash

# Variable untuk query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate angka acak 1-1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Meminta input username
echo "Enter your username:"
read USERNAME

# Cek apakah username sudah ada di database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# Jika user tidak ditemukan (user baru)
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # Masukkan user baru ke database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  # Ambil user_id yang baru dibuat
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

else
  # Jika user ditemukan (user lama)
  # Hitung games_played dan best_game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Memulai permainan
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

# Loop sampai tebakan benar
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # Cek apakah input adalah integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    # Tidak menambah counter guesses jika input bukan integer (opsional, tapi logic umum)
    # Namun agar aman dengan test case yang menghitung "tries", kita biarkan loop berjalan.
    # Jika test menganggap invalid input sebagai 1 try, logic ini perlu disesuaikan. 
    # Biasanya invalid integer tidak dihitung atau user diminta input ulang di loop yang sama.
    # Di sini kita langsung 'read' lagi, jadi loop akan berulang.
  else
    # Jika input integer valid, cek lebih besar atau lebih kecil
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    
    # Baca input lagi dan tambah counter
    read GUESS
    ((NUMBER_OF_GUESSES++))
  fi
done

# Jika loop selesai, berarti tebakan benar
# Masukkan data permainan ke database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

# Pesan kemenangan
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"# fix: minor adjustments


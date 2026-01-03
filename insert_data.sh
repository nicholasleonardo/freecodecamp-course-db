#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Kosongkan tabel sebelum memasukkan data baru (agar tidak duplikat saat testing)
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Baca file games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Lewati baris judul (header)
  if [[ $YEAR != "year" ]]
  then
    # ---------------------------------------------------------
    # 1. MASUKKAN DATA TIM (WINNER)
    # ---------------------------------------------------------
    # Cek apakah team_id winner sudah ada
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Jika tidak ada (kosong)
    if [[ -z $WINNER_ID ]]
    then
      # Insert tim winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      # Dapatkan team_id yang baru saja dibuat
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # ---------------------------------------------------------
    # 2. MASUKKAN DATA TIM (OPPONENT)
    # ---------------------------------------------------------
    # Cek apakah team_id opponent sudah ada
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Jika tidak ada (kosong)
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert tim opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      # Dapatkan team_id yang baru saja dibuat
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # ---------------------------------------------------------
    # 3. MASUKKAN DATA GAMES
    # ---------------------------------------------------------
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR : $ROUND
    fi
  fi
done

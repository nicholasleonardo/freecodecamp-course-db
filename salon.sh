#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Mendapatkan daftar services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # Menampilkan daftar services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Membaca input service
  read SERVICE_ID_SELECTED

  # Cek apakah input berupa angka
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Jika bukan angka, kembali ke menu utama
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Cek ketersediaan service di database
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # Jika service tidak ditemukan
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # === LOGIKA UTAMA SETELAH MEMILIH SERVICE ===

      # Minta nomor telepon
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Cek apakah customer sudah ada
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Jika customer belum ada (hasil query kosong)
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # Insert customer baru
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # Minta waktu appointment
      # Mengambil nama service untuk pesan konfirmasi (dibersihkan dari spasi)
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      # Formatting variabel untuk output yang rapi (menghapus spasi tambahan dari output psql)
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')

      echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME

      # Mendapatkan customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # Insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # Output pesan final
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}

MAIN_MENU

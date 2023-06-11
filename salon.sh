#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Sally's Salty Spatoon Salon ~~~\n\nHello! Thank you for coming to Sally's Salty Spatoon Salon.\nThese are our available services. What can we schedule you for?"

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  # get input from customer
  echo -e "Please select an option below...\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo "(exit)"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-9]) SCHEDULE_MENU ;;
    exit) ;;
    *) MAIN_MENU "'$SERVICE_ID_SELECTED' is not a valid service." ;;
  esac
}

SCHEDULE_MENU() {
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # establish customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nPlease enter your name so we can add you to our system."
    read CUSTOMER_NAME
    echo -e "\nThank you, "$CUSTOMER_NAME""
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    # get customer name
    echo -e "\nWelcome back, $CUSTOMER_NAME!"
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # get service time
  REQUESTED_SERVICE=$($PSQL "SELECT name FROM serviceS WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like to schedule your$REQUESTED_SERVICE?"
  read SERVICE_TIME

  # set appointment
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a$REQUESTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT(){
  echo -e "\nThank you for coming, we'll see you soon!\n"
}

MAIN_MENU
EXIT
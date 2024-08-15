#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c "

echo -e "\n~~~ Welcome to the Salon! ~~~"
echo -e "\nPlease select a service:"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SALON_OPTIONS=$($PSQL "SELECT * FROM services")
  echo "$SALON_OPTIONS" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "Please enter a valid number."
  # else if not an option
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      # send to main menu
      MAIN_MENU "Please select a valid option."
    # else
    else
      # get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      # ask for phone number
      echo -e "\nPlease enter your phone number:"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # if phone number doesn't exist in customers then
      if [[ -z $CUSTOMER_ID ]]
      then
        # ask for name
        echo -e "\nPlease enter your name:"
        read CUSTOMER_NAME
        # enter phone and name into customers if not registered
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
      # ask for time
      echo -e "\nPlease enter the time you would like to be seen:"
      read SERVICE_TIME
      # enter appointment into appointments with joins
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      # notify user that appointment has been made
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
}

MAIN_MENU
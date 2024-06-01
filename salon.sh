#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ WAZZALON ~~~~~\n"

echo -e "Welcome to Wazzalon, how can I help you?" 

MAIN_MENU(){
  # feedback catcher
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  # check if service are  available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry, we dont have any service availabe right now"
  else
    # display service by service id
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME" 
    done
    
    # input service
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
      MAIN_MENU "That's not a number"
    else
      # select service id from input
      SERV_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      # display service name
      NAME_SERV=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      
      if [[ -z $SERV_AVAIL ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        #select phone number
        read CUSTOMER_PHONE

        # check customer name from customers 
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # if name not available, create new name
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # insert new customer into database
          INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")

        fi

        echo -e "\nWhat time would you like your $NAME_SERV, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        # select customer_id for booking appointment
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        
        # booking appointment 
        INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
        
        # print booking accepted
        echo -e "\nI have put you down for a $NAME_SERV at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."



      fi 
    fi
  fi

}


MAIN_MENU



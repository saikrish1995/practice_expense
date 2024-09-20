#!/bin/bash

#Logs should be created in /var/log/practice/scriptname<timestamp>.log

LOGS_FOLDER="/var/log/practice"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"

mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run this script with Super User privilages $N"
    exit 1
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$1 is $R failed $N"
        exit 1
    else
        echo -e "$1 is $G success $N"
    fi
}

dnf install mysql-server -y
VALIDATE "Installing MySQL Server"

systemctl enable mysqld

systemctl start mysqld

# mysql -h 172.31.104.4 -u root -pExpenseApp@1 -e

# mysql_secure_installation --set-root-pass ExpenseApp@1

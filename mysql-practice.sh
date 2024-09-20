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
    echo -e "$R Please run this script with Super User privilages $N" | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$1 is $R failed $N" | tee -a $LOG_FILE 
        exit 1
    else
        echo -e "$1 is $G success $N" | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE "Installing Mysql Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE "Enabled Mysql server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE "Starting Mysql server"

mysql -h 172.31.104.4 -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE

if [ $? -ne 0 ]
then
    echo -e "$R Root Password Not set, setting up now $N" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE "Mysql root password set"
else
    echo -e "Mysql root password already set.. $Y Skipping $N" | tee -a $LOG_FILE
fi

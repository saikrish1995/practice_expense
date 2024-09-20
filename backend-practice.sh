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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE "Install nodejs"

id expense &>>$LOG_FILE

if [ $? -ne 0 ]
then
    echo "expense user not found.. creating now." | tee -a $LOG_FILE
    useradd expense &>>$LOG_FILE
    VALIDATE "Creating expense user"
else
    echo -e "expense user already created..$Y SKIPPING $N" | tee -a $LOG_FILE
fi

mkdir -p /app &>>$LOG_FILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE "downloading backend code"

cd /app

rm -rf /app/*
VALIDATE "removing existing code"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE "extracting backend app code"

npm install &>>$LOG_FILE

cp /home/ec2-user/practice_expense/backend-practice.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE "configuring backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE "install mysql client"

mysql -h 172.31.104.4 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE "Loading schema to mysql"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE "Enable Backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE "restart backend"

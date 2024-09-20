#!/bin/bash

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

dnf install nginx -y &>>$LOG_FILE
VALIDATE "installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE "enabling nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE "remove default page"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE "download frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE "extracting frontend code"

cp /home/ec2-user/practice_expense/frontend-practice.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE

systemctl restart nginx &>>$LOG_FILE
VALIDATE "restarting nginx"

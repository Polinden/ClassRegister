#!/bin/bash

Red='\033[0;31m'       
Green='\033[0;32m'
Yellow='\033[0;33m'
Cyan='\033[0;36m'
NC='\033[0m'
DATE=$(date +%d-%m-%Y)

echo -e "${Cyan}STARTING!${NC}"
echo -e "${Cyan}${DATE}${NC}"
echo "............"

#FILES
CONTROL_FILE='/TEMP/DIAGNOSTICS'
FILE_DUMP='/TEMP/fmh_backup_current.sql'
FILE_LOG1='/var/log/ClassRegister/Errors.log'
FILE_LOG2='/var/log/ClassSetup/Errors.log'
FILE_LOG3='/var/log/ClassRegister/Login.log'
FILE_LOG4='/var/log/ClassRegister/FROMSTARTLogin.log'
FILE_LEN=$((${#FILE_DUMP}-4))   #MINUS EXTENTION
FILE_DUMP_ARCH="${FILE_DUMP:0:$FILE_LEN}.tar.gz"

#START DATE FINDING
TK="/opt/tomcat" 
TK_DATE=$(ls -ltrh --time-style=+%d-%m-%Y /proc | grep $(ps axf | grep $TK | grep -v grep | awk '{print $1}') | awk '{print $6}')
echo -e "${Green}System (re)started on $TK_DATE!${NC}"
echo ""

#MEM_TEST AND DISK 
MEM_TEST="Свободно памяти $(free -m | awk '{split ($_, a, "^(Mem:)"); if (length(a[2])>0) {x=a[2]; split(x, b, "\\s+"); print b[4]}}')Мб \
или $(free -m | awk '{split ($_, a, "^(Mem:)"); if (length(a[2])>0) {x=a[2]; split(x, b, "\\s+"); printf "%5.2f", b[4]/1024}}')%"
DISK_TEST="$(df -kh . | tail -1 | awk '{split($_, a, /\s+/); printf "На диске занято %s из %s\n", a[3], a[2]}')"
#echo -e "${Red}$MEM_TEST${NC}"
#echo -e "${Red}$DISK_TEST${NC}"
#echo ""

#PREPARE  - CLEAN THE STORAGE
rm $FILE_DUMP
rm $FILE_DUMP_ARCH
rm $CONTROL_FILE

#DUMP DATABASE - AT FIRST
su -c "pg_dump -C -F p -f $FILE_DUMP fmh" -l postgres
if [ $? -eq 0 ]; then
    echo -e "${Green}Postgres DataBase Dump IS READY!${NC}"
else
    echo -e "${Red}Error happend when dumping!${NC}"
fi

#UPLOAD DATABASE DUMP - AT SECOND
if [ -f $FILE_DUMP ]; then
   tar -czf $FILE_DUMP_ARCH $FILE_DUMP
   /usr/local/bin/copyDBX.py -i $FILE_DUMP_ARCH -f BackUps
else
   echo -e "${Red}File $FILE_DUMP does not exist!${NC}"
fi


#UPLOAD ERRORLOGS IF EXIST AND NOT EMPTY
ERR1=0
ERR2=0
if [ -f $FILE_LOG1 ]; then
   ERR1=$(wc -l < ${FILE_LOG1})
   case $ERR1 in
     0)  echo -e "${Green}No ERRORS in ${FILE_LOG1}!${NC}"
       ;;
     *)/usr/local/bin/copyFILEDVX.py -i $FILE_LOG1 -o ErrorLogs/RegisterErrors.log
       ;;
   esac 
else
   echo -e "${Red}File $FILE_LOG1 does not exist!${NC}"
fi
if [ -f $FILE_LOG2 ]; then
   ERR2=$(wc -l < ${FILE_LOG2})
   case $ERR2 in
     0)  echo -e "${Green}No ERRORS in ${FILE_LOG2}!${NC}"
       ;;
     *) /usr/local/bin/copyFILEDVX.py -i $FILE_LOG2 -o ErrorLogs/SetupErrors.log
       ;;
   esac 
else
   echo -e "${Red}File $FILE_LOG2 does not exist!${NC}"
fi


#UPLOAD THIS SCRIPT ITSELF ON FRIDAYS
if [ $(date +%u) -eq 5 ]; then 
   echo -e "${Green}Uploading self!${NC}"
   /usr/local/bin/copyFILEDVX.py -i /usr/local/bin/backupFMH.sh -o SetUps/backupFMH.sh
   /usr/local/bin/copyFILEDVX.py -i /usr/local/bin/copyFILEDVX.py -o SetUps/copyFILEDVX.py 
   /usr/local/bin/copyFILEDVX.py -i /usr/local/bin/copyDBX.py -o SetUps/copyDBX.py 
fi


#DIAGNOSTICS
echo -e "${Green}Posting Diagnostics to Dropbox!${NC}"
VISITORS=$(wc -l < ${FILE_LOG3})
touch $CONTROL_FILE
touch $FILE_LOG4
cat $FILE_LOG3 >> $FILE_LOG4
cat /dev/null >  $FILE_LOG3 
VISITORS_ALL=$(wc -l < ${FILE_LOG4})

for i in {1..72}; do echo -n "_"  >> $CONTROL_FILE; done
echo ""  >> $CONTROL_FILE
echo "Уважаемый АДМИНИСТРАТОР!" >> $CONTROL_FILE
for i in {1..72}; do echo -n "_"  >> $CONTROL_FILE; done
echo ""  >> $CONTROL_FILE
if [ -f $FILE_DUMP_ARCH ]; then
   echo "Последний бэкап баз данных сделан ${DATE}" >> $CONTROL_FILE
else
   echo "Попытка сделать бекап БД от ${DATE} не удалась!" >> $CONTROL_FILE
fi
echo ""  >> $CONTROL_FILE
echo "Сайт вчера посетило: ${VISITORS}чел." >> $CONTROL_FILE
echo "Сайт с НАЧАЛА РАБОТЫ  посетило: ${VISITORS_ALL}чел." >> $CONTROL_FILE
echo ""  >> $CONTROL_FILE
echo "Сайт (ре)стартовал $TK_DATE" >> $CONTROL_FILE
echo "$MEM_TEST" >> $CONTROL_FILE
echo "$DISK_TEST" >> $CONTROL_FILE
echo ""  >> $CONTROL_FILE
echo "Свежая дата бэкапа и число посещений>0 говорят о том, что САЙТ РАБОТАEТ!" >> $CONTROL_FILE
for i in {1..72}; do echo -n "_"  >> $CONTROL_FILE; done
echo ""  >> $CONTROL_FILE
if [ $(($ERR1+$ERR2)) -eq 0 ] ; then
   echo "Ошибок не выявлено!" >> $CONTROL_FILE 
else
   echo "Смотрите логи ошибок! В них $(($ERR1+$ERR2)) ошибки(у)!" >> $CONTROL_FILE
fi
for i in {1..72}; do echo -n "_"  >> $CONTROL_FILE; done

/usr/local/bin/copyFILEDVX.py -i $CONTROL_FILE -o README_I_AM_DIAGNOSTICS.txt


echo "..........."
echo -e "${Yellow}EVERYTHING IS DONE!${NC}"

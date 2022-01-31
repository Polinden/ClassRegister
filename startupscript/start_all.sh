rm -f /etc/localtime
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

locale-gen uk_UA.UTF-8
cat >> nano /etc/environment <<EOL
LC_ALL=ru_UA.UTF-8
LANG=ru_UA.UTF-8
LC_CTYPE=ru_UA.UTF-8
LC_NUMERIC=ru_UA.UTF-8
LC_TIME=ru_UA.UTF-8
LC_COLLATE=ru_UA.UTF-8
LC_MONETARY=ru_UA.UTF-8
LC_MESSAGES=ru_UA.UTF-8
EOL

export LANG=ru_UA.UTF-8
export C_CTYPE="ru_UA.UTF-8"
export C_NUMERIC="ru_UA.UTF-8"
export export LC_TIME="ru_UA.UTF-8"
export LC_COLLATE="ru_UA.UTF-8"
export LC_MONETARY="ru_UA.UTF-8"
export LC_MESSAGES="ru_UA.UTF-8"
export LC_ALL=ru_UA.UTF-8



mkdir /TEMP
chmod 777 /TEMP
cd /TEMP


apt install -y software-properties-common
add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"
wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install -y postgresql-9.11 postgresql-contrib

cat >> temt.tt <<EOL
create role fmh password 'misha' login
create database fmh
EOL
sudo -u postgres psql < temp.tt
rm temp.tt
sudo -u postgres psql < dump.sql

wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz

wget http://apache.cp.if.ua/tomcat/tomcat-9/v9.0.29/bin/apache-tomcat-9.0.29.tar.gz
mkdir /opt/tomcat
tar xvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
tar xvf openjdk*tar.gz -C /opt/java –strip-components=1
update-alternatives --install /usr/bin/java java /opt/java/bin/java 0

cat >> /etc/systemd/system/tomcat.service << EOL
[Unit]
Description=Tomcat9
After=network.target

[Service]
Type=forking

Environment=CATALINA_PID=/opt/tomcat/tomcat9.pid
Environment=JAVA_HOME=/opt/java                         
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment="CATALINA_OPTS=-Xms512m -Xmx512m"
Environment="JAVA_OPTS=-Dfile.encoding=UTF-8 -Dnet.sf.ehcache.skipUpdateCheck=true -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled $
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOL


#set password for tomcat admin
mv /opt/tomcat/conf/tomcat-users.xml /opt/tomcat/conf/tomcat-users.old  
head -n -1 /opt/tomcat/conf/tomcat-users.old  > /opt/tomcat/conf/tomcat-users.xml
cat >> /opt/tomcat/conf/tomcat-users.xml <<EOL 
<user username="papa" password="****"" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOL

mv /opt/tomcat/webapps/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/context.old  
head -n -6 /opt/tomcat/webapps/manager/META-INF/context.old  > /opt/tomcat/webapps/manager/META-INF/context.xml
cat >> /opt/tomcat/webapps/manager/META-INF/context.xml <<EOL 
<Context antiResourceLocking="false" privileged="true" >
 <!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfP$
 >-->
</Context>
EOL

cp jaxb-api-2.3.1.jar /opt/tomcat/lib/jaxb-api-2.3.1.jar

systemctl daemon-reload
service tomcat enable
service tomcat start

apt install -y python3-pip
pip3 install dropbox

cp backupFMH.sh /TEMP/backupFMH.sh
cp copyFILEDVX.py /TEMP/copyFILEDVX.py
cp copyDBX.py /TEMP/copyDBX.py


chmod 777 /TEMP/backupFMH.sh
chmod 777 /TEMP/copyFILEDVX.py
chmod 777 /TEMP/copyDBX.py

rontab -l > mycron
echo "0 4 * * * /TEMP/backupFMH.sh" >> mycron
crontab mycron
rm mycron

#!/bin/bash
ABSOLUTE_FN=`readlink -e "$0"` #Путь к файлу
DIRECTORY=`dirname "$ABSOLUTE_FN"` #путь к директории

clear
len=81 && while ((--len)) ; do echo -n _ ; done && echo
echo "========Install HASHSTREM Client (Linux)========="


#Find process and notify the user
if [ "$(pidof HSClient)" ]; then 
		echo -e "\e[1;32m The client is currently running, stop it and try again. \e[0m";
		exit 0;
fi


read -p "(STEP 1 in 2) | Enter the IP address of yor server HASHSTREM:   " IPADDR

		#Указание дефолтного значения
		if [ -z "$IPADDR" ]; then
			echo -e "\e[1;33m - Use IP: 192.168.1.33 - DEFFAULT \e[0m";
			IPADDR=192.168.1.33
		else
			echo -e "\e[1;33m - Use IP: $IPADDR \e[0m";
		fi

read -p "(STEP 2 in 2) | Enter the PORT of yor server HASHSTREM (DEFFAULT 17900):   " PRT

		if [ -z "$PRT" ]; then
			echo -e "\e[1;33m - Use port: 17900 - DEFFAULT\e[0m";
			PRT=17900
		else
			echo -e "\e[1;33m - Use port: $PRT \e[0m";
		fi



echo "";
echo -e "\e[32m - Create file configuration... \e[0m"

#Delete old config
if [ -f "./config.json" ]; then
	rm ./config.json
fi
#Create file configuration
echo "
{
    \"connect\": [
        {
            \"host\": \"$IPADDR\",
            \"port\": \"$PRT\"
        }
    ],
    \"comment\": \"new_stantion\",
    \"MinerName\": \"not installed\",
    \"MinerPath\": \"\",
    \"MinerKey\": \"ZGlzYWJsZWQ=\"
}" >> config.json

echo -e "\e[32m - Download HS Client... \e[0m"
if [ -f "./HSC.tgz" ]; then
	rm ./HSC.tgz
fi

wget http://data-hs.gq/linux/HSC.tgz
echo -e "\e[32m - Install HS module... \e[0m"
tar -zxvf HSC.tgz
rm HSC.tgz

#Install dependencies?
while true; do
	read -p "To install the dependencies for the standard miner HS | (Y\N)?   " yn
	case $yn in
		[Nn]* ) 	break;;
		[Yy]* )		yum -y install libuv1-dev libssl-dev libhwloc-dev;
					break;;
			* ) 	echo -e "\e[1;33m Please answer yes or no. \e[0m";;
	esac
done

#Start HSClient
while true; do
	read -p "Run the client automatically after restarting (You need to enter the root password) | (Y\N)?   " yn
	case $yn in
		[Nn]* ) 	echo "Automatic start is disabled."; 
					./HSClient;
				 	break;;
		[Yy]* )	
					echo "Automatic start is enabled.";
					chmod +x HSClient;
					$DIRECTORY/HSClient -addsvc;
					update-rc.d HSC defaults;
					service HSC start;
					break;;
		* ) 
					echo -e "\e[1;33m Please answer yes or no. \e[0m";;
	esac
done

#Find process and notify the user
if [ "$(pidof HSClient)" ]; then 
		echo -e "\e[1;32m HASHSTREM CLIENT IS CURRENTLY RUNNING. \e[0m";
	 else 
		echo -e "\e[1;31m HASHSTREM CLIENT LAUNCH ERROR. \e[0m";
fi;


#!/bin/bash
# NPT - Network Performance Tester.
# Bash script for check internet performance 
# Copyright (c) 2015 Luca Santacatterina  <s88.luca@gmail.com>
# License: MIT, see LICENSE file


# Hosts list of ping servers
hosts_server=(
	'gw.mix-it.net'
	'rs1.ams-ix.net'
	)


download_server=(
	'ftp.de.debian.org/debian/ls-lR.gz'
	'ftp.fr.debian.org/debian/ls-lR.gz'
	'ftp.it.debian.org/debian/ls-lR.gz'
	'ftp.nl.debian.org/debian/ls-lR.gz'
	'ftp.uk.debian.org/debian/ls-lR.gz'
	)


# Number of ping test
ping_count=20


# Save file log
log_file="NPT_log.txt"


# Start time an date
date_start=$(date +"%d/%m/%Y %H:%M")


# Software required
required_sw=(
	'curl'
	'mtr'
	'tee'
	)


# Check dependencies
is_required_sw=false
for r in ${required_sw[@]}; do
	if ! command -v $r >/dev/null; then
		echo "ERROR :" ${r} "does not exist in your system"
		is_required_sw=true
	fi
done


# Exit if dependencies not satisfied
if [ ${is_required_sw} = true ] ; then
	exit 0
fi


# Verify if a file exists and delete first
if [ -f ${log_file} ]
then
	rm ${log_file}
fi

# Start print to file details
echo "****************************************************************************" | tee -a $log_file
echo " NPT - Network Performance Tester" | tee -a $log_file
echo " Start time:" $date_start | tee -a $log_file
echo "****************************************************************************" | tee -a $log_file


# Verify traceroute and ping
for server in ${hosts_server[@]}; do
	echo | tee -a $log_file
	echo "Server:" ${server} | tee -a $log_file
	mtr -rnc ${ping_count} ${server} | tee -a $log_file
done


for site in ${download_server[@]}; do

	echo | tee -a $log_file

	http_download_speed=$(curl -w '%{speed_download}' -m 15 -s -o /dev/null "http://${site}")
	http_download_speed=${http_download_speed/,/.}
	http_download_speed=$(echo "scale=2; ($http_download_speed*8)/(1000*1000)" | bc)
	echo -e "Download HTTP da http://${site} :\t" $http_download_speed "Mbps" | tee -a $log_file

	ftp_download_speed=$(curl -w '%{speed_download}' -m 15 -s -o /dev/null "ftp://${site}")
	ftp_download_speed=${ftp_download_speed/,/.}
	ftp_download_speed=$(echo "scale=2; ($ftp_download_speed*8)/(1000*1000)" | bc)
	echo -e "Download FTP  da ftp://${site}  :\t" $ftp_download_speed "Mbps" | tee -a $log_file

done
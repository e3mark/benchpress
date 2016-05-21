#!/bin/bash

#reference: https://wiki.mikejung.biz/Sysbench

mysql_host='192.168.100.222'
mysql_db='sysbench'
mysql_user='e3mark'
mysql_password=''

lua=/usr/share/doc/sysbench/tests/db/
oltp_prepare=$lua/parallel_prepare.lua
oltp_insert=$lua/insert.lua
oltp_test=$lua/oltp.lua

oltp_prepare () {
	sysbench \
	--test=$oltp_prepare \
	--mysql-host=$mysql_host \
	--mysql-db=$mysql_db \
	--mysql-user=$mysql_user \
	--mysql-password=$mysql_password \
	--mysql-table-engine=innodb \
	--oltp-test-mode=complex \
	--oltp-read-only=off \
	--oltp-reconnect=on \
	--oltp-table-size=1000000 \
	--max-requests=100000000 \
	--num-threads=3 \
	--report-interval=1 \
	--report-checkpoints=10 \
	--tx-rate=24 \
	run;
}

oltp_insert () {
	sysbench \
	--test=$oltp_insert \
	--mysql-host=$mysql_host \
	--mysql-db=$mysql_db \
	--mysql-user=$mysql_user \
	--mysql-password=$mysql_password \
	--mysql-table-engine=innodb \
	--oltp-test-mode=complex \
	--oltp-read-only=off \
	--oltp-reconnect=on \
	--oltp-table-size=1000000 \
	--max-requests=100000000 \
	--num-threads=3 \
	--report-interval=1 \
	--report-checkpoints=10 \
	--tx-rate=24 \
	run;
}

# This script will run 6 tests, each lasting 4 minutes. 
# It will run 1 through 64 threaded tests, which seem to be the most common tests to run. 
# This test does selects, updates, and various other things and is considered 
# to be a "read / write" MySQL mixed workload.
rw () {
	for each in 1 4 8 16 32 64; do 
		sysbench \
		--test=$oltp_test \
		--mysql-host=$mysql_host \
		--mysql-db=$mysql_db \
		--mysql-user=$mysql_user \
		--mysql-password=$mysql_password \
		--oltp-table-size=20000000 \
		--max-time=240 \
		--max-requests=0 \
		--num-threads=$each \
		run; 
	done
}

rr () {
	for each in 1 4 8 16 32 64; do 
		sysbench \
		--test=$oltp_test \
		--mysql-host=$mysql_host \
		--mysql-db=$mysql_db \
		--mysql-user=$mysql_user \
		--mysql-password=$mysql_password \
		--oltp-table-size=20000000 \
		--max-time=240 \
		--max-requests=0 \
		--num-threads=$each \
		--oltp-read-only=on \
		run; 
	done
}


fileio () {
	# ../sandbox1.sh -fileio prepare 4
	if [ $1 == "prepare" ];
	then
		num=$2
		filesize=$num'G'
		filenum=$((num * 16))
		sysbench --test=fileio --file-total-size=$filesize --file-num=$filenum prepare
	else
		for run in 1 2 3; do
			for thread in 1 4 8 16 32; do
				echo "Performing test RW-${thread}T-${run}"
				sysbench \
				--test=fileio \
				--file-total-size=4G \
				--file-test-mode=rndwr \
				--max-time=60 \
				--max-requests=0 \
				--file-block-size=4K \
				--file-num=64 \
				--num-threads=${thread} \
				run > /home/e3mark/Projects/benchpress/logs/RW-${thread}T-${run}

				echo "Performing test RR-${thread}T-${run}"
				sysbench \
				--test=fileio \
				--file-total-size=4G \
				--file-test-mode=rndrd \
				--max-time=60 \
				--max-requests=0 \
				--file-block-size=4K \
				--file-num=64 \
				--num-threads=${thread} \
				run > /home/e3mark/Projects/benchpress/logs/RR-${thread}T-${run}
			done
		done
	fi
}

cpu () {
	sysbench --test=cpu --cpu-max-prime=20000 run
}

# Todo: check installed sysbench version if >= 0.5.*
echo "Positional Parameters"
echo '$0 = ' $0
echo '$1 = ' $1
echo '$2 = ' $2
echo '$3 = ' $3

case $1 in
	'-fileio')
		fileio $2 $3;;
	'-mysql_prepare')
		prepare;;
	'-mysql_insert')
		insert;;
	'-rw')
		rw;;
	'-rr')
		rr;;
	*)
		;;
esac

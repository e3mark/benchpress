#!/bin/bash
#####################################################################
# License: GNU General Public License 3.0                           #
# Github: https://github.com/e3mark/benchpress                      #
#####################################################################
sysinfo () {
	logfile=$HOME/benchpress.log
	# Removing existing bench.log
	rm -rf $logfile
	# Reading out system information...
	# Reading CPU model
	cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	# Reading amount of CPU cores
	cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
	# Reading CPU frequency in MHz
	freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	# Reading total memory in MB
	tram=$( free -m | awk 'NR==2 {print $2}' )
	# Reading Swap in MB
	vram=$( free -m | awk 'NR==4 {print $2}' )su
	# Reading system uptime
	up=$( uptime | awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }' | sed 's/^[ \t]*//;s/[ \t]*$//' )
	# Reading operating system and version (simple, didn't filter the strings at the end...)
	opsy=$( cat /etc/issue.net | awk 'NR==1 {print}' ) # Operating System & Version
	arch=$( uname -m ) # Architecture
	lbit=$( getconf LONG_BIT ) # Architecture in Bit
	hn=$( hostname ) # Hostname
	kern=$( uname -r )
	# Date of benchmark
	bdates=$( date )
	echo "Benchmark started on $bdates" | tee -a $logfile
	echo "Full benchmark log: $logfile" | tee -a $logfile
	echo "" | tee -a $logfile
	# Output of results
	echo "System Info" | tee -a $logfile
	echo "-----------" | tee -a $logfile
	echo "Processor	: $cname" | tee -a $logfile
	echo "CPU Cores	: $cores" | tee -a $logfile
	echo "Frequency	: $freq MHz" | tee -a $logfile
	echo "Memory		: $tram MB" | tee -a $logfile
	echo "Swap		: $vram MB" | tee -a $logfile
	echo "Uptime		: $up" | tee -a $logfile
	echo "" | tee -a $logfile
	echo "OS		: $opsy" | tee -a $logfile
	echo "Arch		: $arch ($lbit Bit)" | tee -a $logfile
	echo "Kernel		: $kern" | tee -a $logfile
	echo "Hostname	: $hn" | tee -a $logfile
	echo "" | tee -a $logfile
	echo "" | tee -a $logfile
}
removesb(){
	#debian
	sudo apt-get purge sysbench
	#fedora
	
}
manual () {
	echo ""
	echo "(C) benchpress.sh"
	echo ""
	echo "Usage: benchpress.sh <option>"
	echo ""
	echo "Available options:"
	echo "No option	: blah"
	echo "-foo		: blah"
	echo ""
}
case $1 in
	'-sys')
		sysinfo;;
	'-h' )
		manual;;
	*)
		sysinfo; manual;;
esac

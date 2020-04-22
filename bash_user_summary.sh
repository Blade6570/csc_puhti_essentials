#!/bin/bash
#This is a script to find the resources in Puhti cluster/CSC
#Developed in Tampere University, Computer-Vision Group.
####################################################################################
#sinfo -N -p gpu -o %a -O "nodehost,available,cpus,cpusload,cpusstate" --noheader
#sinfo -N -p gpu -o %a -O "nodehost,available,cpusstate" --noheader
# find the nodes with least CPU usage: in gpu partition: 1 in the cut command stands for allocated cpus in a node, 2 will stand for idle, 3 for other and 4 for total which is 40.
#echo
#echo 'Recommended node with least amount of CPU usages |N|S|Coresinuse|'
#CPU=`sinfo -N -p gpu -o %a -O "nodehost,available,cpusstate" --noheader | cut -d "/" -f 1 | sort -nr -k3 | tail -10`
#echo "$CPU"
#Total number of gpus in use
#####################################################################################
echo
echo '*** WELCOME TO DYNAMIC PUHTI-RESOURCE FINDER SYSTEM ***'
echo
#####################################################################################

# HEADER 
printf '%10s %4s %3s %7s' "USER" "CPU" "GPU" "CPU/GPU"
echo

unique_users=`squeue -h -p gpu -o "%u" | sort | uniq`

for value in $unique_users
	do
		gpu_in_use=`sacct -n -X --state running --user  $value --format=jobid,elapsed,ncpus,ntasks,state,AllocGRES | awk '{print $5}' | awk -F '[ :]' '{print $2}' | awk '{s+=$1} END {print s}'`
		cpu_in_use=`sacct -n -X --state running --user  $value --format=jobid,elapsed,ncpus,ntasks,state,AllocGRES | awk '{print $3}' | awk '{s+=$1} END {print s}'`

		# if $gpu_in_use is empty, then a user waits in the queue CPU/GPU is -1
		if [ -z "$gpu_in_use" ]
		then
			cpu_per_gpu=`echo -1`
		else
			cpu_per_gpu=`echo $cpu_in_use / $gpu_in_use | bc -l`
		fi

		while IFS= read -r -u2 u && read -r -u3 a && read -r -u4 b && read -r -u5 c; do
			printf '%10s %4d %3s %7.1f\n' "$u" "$a" "$b" "$c"
		done 2<<<"$value" 3<<<"$cpu_in_use" 4<<<"$gpu_in_use" 5<<<"$cpu_per_gpu"
	done
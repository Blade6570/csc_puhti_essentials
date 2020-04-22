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
 echo '|USER|CPUs_in_use|GPUs_in_use|'
 echo


unique_users=`squeue -h -p gpu -o "%u" | sort | uniq`

for value in $unique_users
 do
     #if ['$value' != 'USER'];
     #then
	 gpu_in_use=`sacct -n -X --state running --user  $value --format=jobid,elapsed,ncpus,ntasks,state,AllocGRES | awk '{print $5}' | awk -F '[ :]' '{print $2}' | awk '{s+=$1} END {print s}'`
 	 cpu_in_use=`sacct -n -X --state running --user  $value --format=jobid,elapsed,ncpus,ntasks,state,AllocGRES | awk '{print $3}' | awk '{s+=$1} END {print s}'`

	 while IFS= read -r -u2 u && read -r -u3 a && read -r -u4 b; do
	     printf '%s%10s%10s\n' "$u" "$a" "$b"
	 done 2<<<"$value" 3<<<"$cpu_in_use" 4<<<"$gpu_in_use"

	 echo
	 #echo $cpu_in_use
     #fi
 done

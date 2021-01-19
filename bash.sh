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

total_gpu_in_use=`squeue -h -t R -p gpu -o "%.10b %10D" | awk -F'[: ]' '{print $3 * $4}' | paste -sd+ | bc`
total_gpu=`sinfo -N -p gpu -o %a -O "gres" --noheader | wc -l`
mul_fac=4
total_gpu_in_csc=$(echo "${total_gpu}*${mul_fac}" | bc -l)

echo Total GPUs in CSC: "$total_gpu_in_csc "

echo

echo Total GPUs are in use: "$total_gpu_in_use "


echo
#####################################################################################
#echo 'Recommended node with least amount of GPU usages |N|GPUinuse|'
#GPU=`squeue -h -t R -p gpu -o"%N %b" | cut -d "," -f 1 | awk -F '[ :]' '{print $1 "\t" $4 }' | sort -n -k2 |awk '{ seen[$1] += $2 } END { for (i in seen) print i, seen[i] }' | sort -n -k2| tail -10`

#echo "$GPU"
#####################################################################################

#####################################################################################
gpu_nodes=`squeue -h -t R -p gpu -o"%N %b" | cut -d "," -f 1 | awk -F '[ :]' '{print $1 "\t" $4 }' | sort -nr -k2 | awk '{ seen[$1] += $2 } END { for (i in seen) print i, seen[i] }' | sort -nr -k2 | tail -20 | awk '{print $1}' ORS=','`
#cpu_nodes=`sinfo -N -p gpu -o %a -O "nodehost,available,cpusstate" --noheader | cut -d "/" -f 1 | awk '{print $1}'`

gpu_inuse=`squeue -h -t R -p gpu -o"%N %b" | cut -d "," -f 1 | awk -F '[ :]' '{print $1 "\t" $4 }' | sort -nr -k2 |awk '{ seen[$1] += $2 } END { for (i in seen) print i, seen[i] }' | sort -nr -k2| tail -20 | sort -n -k1 | awk '{print $2}'`

#echo "$gpu_inuse"

cpu_inuse=`sinfo -N -p gpu -n $gpu_nodes -o %a -O "nodehost,available,cpusstate" --noheader`
#echo "$cpu_inuse"

echo '*******************STATISTICS*******************'

echo

echo '|Node|Status|CPUstate(aloc/idle/others/total)|GPUsinuse|'
echo



while IFS= read -r -u3 a && read -r -u4 b; do
  printf '%s\t%s\n' "$a" "$b"
done 3<<<"$cpu_inuse" 4<<<"$gpu_inuse"

echo


echo IDLE NODES if any:

echo
idle_gpu=`sinfo -p gpu | grep idle | awk '{print $6}' `

echo "$idle_gpu "

echo

echo 'Happy finding!'
echo
#####################################################################################

#|  echo "$gpu_inuse"

#squeue -h -t R -p gpu -o"%N %b" | cut -d "," -f 1 | awk -F '[ :]' '{print $1 "\t" $4 }' | sort -n -k2 |  awk '$1!=p{ if (NR>1) print p, s; p=$1; s=0} {s+=$2} END{print p, s}' | sort -n -k2  | awk '{print $2}' | paste -sd+ | bc

#eval squeue -h -t R -O gres | grep gpu:v100: |  cut -b 10 |  paste -sd+ | bc

#! /bin/bash
FOLDERS=(1_1 1_2 1_3 1_4 2_3);
GREEN='\033[0;32m'
echo -en "${GREEN}=============================================================================================================\n"
echo -en "${GREEN}||      ___           ___           ___                                ___           ___           ___     ||\n"
echo -en "${GREEN}||     /\  \         /\  \         /\  \                   ___        /\__\         /\  \         /\  \    ||\n"
echo -en "${GREEN}||    /::\  \        \:\  \       /::\  \                 /\  \      /::|  |       /::\  \       /::\  \   ||\n"
echo -en "${GREEN}||   /:/\:\  \        \:\  \     /:/\:\  \                \:\  \    /:|:|  |      /:/\:\  \     /:/\:\  \  ||\n"
echo -en "${GREEN}||  /::\~\:\  \       /::\  \   /:/  \:\  \               /::\__\  /:/|:|  |__   /::\~\:\  \   /:/  \:\  \ ||\n"
echo -en "${GREEN}|| /:/\:\ \:\__\     /:/\:\__\ /:/__/ \:\__\    ==     __/:/\/__/ /:/ |:| /\__\ /:/\:\ \:\__\ /:/__/ \:\__\||\n"
echo -en "${GREEN}|| \/_|::\/:/  /    /:/  \/__/ \:\  \ /:/  /    ==    /\/:/  /    \/__|:|/:/  / \/__\:\ \/__/ \:\  \ /:/  /||\n"
echo -en "${GREEN}||    |:|::/  /    /:/  /       \:\  /:/  /           \::/__/         |:/:/  /       \:\__\    \:\  /:/  / ||\n"
echo -en "${GREEN}||    |:|\/__/     \/__/         \:\/:/  /             \:\__\         |::/  /         \/__/     \:\/:/  /  ||\n"
echo -en "${GREEN}||    |:|  |                      \::/  /               \/__/         /:/  /                     \::/  /   ||\n"
echo -en "${GREEN}||     \|__|                       \/__/                              \/__/                       \/__/    ||\n"
echo -en "${GREEN}=============================================================================================================\n"
tput sgr0



function get_instance_info {
	
echo "================================================================================"
echo "Starting get info for 1.1"
echo "Get information for SHUTOFF or ERROR instances list..."
openstack server list --all --sort-column Status | grep -E 'ERROR|SHUTOFF' > instances_info.log
LIST_IDS=$(cat instances_info.log | awk '{print $2}' | wc -l)
echo "All instances $LIST_IDS"
echo "Get ID user, create instances..."
echo "Instance, ID-Instance, Status, ID-user-create-vm, info-user-create-vm" \
 >> ./1_1/instances_table.csv


for (( i=1; i <= ${LIST_IDS}; i++ ))
	do

	TEMP_INSTANCES_NAME=$(cat instances_info.log | awk '{print $4}' | head -n ${i} | tail -n 1) 
	TEMP_INSTANCES_ID=$(cat instances_info.log | awk '{print $2}' | head -n ${i} | tail -n 1) 
	TEMP_INSTANCES_STATUS=$(cat instances_info.log | awk '{print $6}' | head -n ${i} | tail -n 1)
	TEMP_USER_ID=$(openstack server show $TEMP_INSTANCES_ID -c user_id -f value)
	TEMP_USER_INFO=$(openstack user show $TEMP_USER_ID -c name -f value)
	
	echo "$TEMP_INSTANCES_NAME, $TEMP_INSTANCES_ID, $TEMP_INSTANCES_STATUS, \
	 $TEMP_USER_ID, $TEMP_USER_INFO" >> ./1_1/instances_table.csv
	
	done
	
echo -e "Step 1.1 is done, see file:\ninstances_table.csv"
echo "================================================================================"
}

function get_ports_info {
	
echo "================================================================================"
echo "Starting get info for 1.2"
echo "Get information for DOWN ports list..."
openstack port list | grep 'DOWN' | grep -vE 'okd-|vip-port' > ports_info.log
LIST_IDS=$(cat ports_info.log | awk '{print $2}' | wc -l)
echo "All ports DOWN $LIST_IDS"
echo "Generate other information: ID, IP, STATUS, SUBNET and INSTANCES "
echo "ID, STATUS, IP, SUBNET_ID, INSTANCE" >> ./1_2/ports_table.csv

for (( i=1; i <= ${LIST_IDS}; i++ ))
	do
	TEMP_EXIST=$(cat ports_info.log | head -n ${i} | tail -n 1 | wc -w)
	if [ "$TEMP_EXIST" -lt "12" ]; then continue; fi
	TEMP_PORT_ID=$(cat ports_info.log | awk '{print $2}' | head -n ${i} | tail -n 1)
	TEMP_PORT_IP=$(cat ports_info.log | awk '{print $8}' | head -n ${i} | tail -n 1 | sed -r 's/ip_address=//' | sed -r "s/'//g" | sed -r "s/,//")
	TEMP_PORT_STATUS=$(cat ports_info.log | awk '{print $11}' | head -n ${i} | tail -n 1)
	TEMP_PORT_SUBNET=$(cat ports_info.log | awk '{print $9}' | head -n ${i} | tail -n 1 | sed -r 's/subnet_id=//' | sed -r "s/'//" | sed -r "s/'//")
	TEMP_INSTANCES=$(openstack port show $TEMP_PORT_ID -c tags -f value | sed 's/[][]//g' | sed -r "s/'//g" | sed -r "s/,//g" | sed -r "s/migration//")
	
	echo "$TEMP_PORT_ID, $TEMP_PORT_STATUS, $TEMP_PORT_IP, $TEMP_PORT_SUBNET, $TEMP_INSTANCES" >> ./1_2/ports_table.csv
		  
	done


echo -e "Step 1.2 is done, see file:\nports_table.csv"
echo "================================================================================"
}

function get_security_group_info {
	
echo "================================================================================"
echo "Starting get info for 1.3"
echo "Get information for security groups list for which no longer exists project..."

openstack project list -f value > projects_info.log
openstack security group list -f value > sec_group_info.log
openstack security group list -c Project -f value > sec_group_id_project.log

LIST_PROJECTS=$(cat projects_info.log | awk '{print $1}' | wc -l)
LIST_SEC_GROUP=$(cat sec_group_info.log | awk '{print $1}' | wc -l)
echo "Security group name, Security group ID, Security group project id (doesn't exist)" >> ./1_3/secgroup_table.csv


for (( i=1; i <= ${LIST_SEC_GROUP}; i++ ))
	do
	TEMP_SECGROUP_ID=$(cat sec_group_info.log | awk '{print $1}' | head -n ${i} | tail -n 1)
	TEMP_SECGROUP_NAME=$(cat sec_group_info.log | awk '{print $2}' | head -n ${i} | tail -n 1)
	TEMP_SECGROUP_PROJECT=$(cat sec_group_id_project.log | awk '{print $1}' | head -n ${i} | tail -n 1)
	TEMP_BOOL_EQ=$(cat projects_info.log | grep "$TEMP_SECGROUP_PROJECT" | wc -l)
	if [ "$TEMP_BOOL_EQ" != "0" ]; then continue;
	else
		
		echo "$TEMP_SECGROUP_NAME, $TEMP_SECGROUP_ID, $TEMP_SECGROUP_PROJECT" >> ./1_3/secgroup_table.csv
	
	fi	
		  
	done
echo -e "Step 1.3 is done, see file:\nsecgroup_table.csv"
echo "================================================================================"
}

function get_volumes_info {
	
echo "================================================================================"
echo "Starting get info for 1.4"
echo "Get information for not actual volumes..."
openstack volume list --all | grep 'available' | grep -vE 'okd-|image-|iso|Attached' > not_actuale_volumes_info.log
LIST_DISKS=$(cat not_actuale_volumes_info.log | awk '{print $2}' | wc -l)
echo "DISK_NAME, VOLUME_ID, STATUS, SIZE, USER_ID, USER_NAME" \
 >> ./1_4/volumes_table.csv

for (( i=1; i <= ${LIST_DISKS}; i++ ))
	do

	TEMP_VOLUME_NAME=$(cat not_actuale_volumes_info.log | awk '{print $4}' | head -n ${i} | tail -n 1) 
	TEMP_VOLUME_STATUS=$(cat not_actuale_volumes_info.log | awk '{print $6}' | head -n ${i} | tail -n 1) 
	TEMP_VOLUME_SIZE=$(cat not_actuale_volumes_info.log | awk '{print $8}' | head -n ${i} | tail -n 1)
	TEMP_VOLUME_ID=$(cat not_actuale_volumes_info.log | awk '{print $2}' | head -n ${i} | tail -n 1) 
	TEMP_USER_ID=$(openstack volume show $TEMP_VOLUME_ID -c user_id -f value)
	TEMP_USER_INFO=$(openstack user show $TEMP_USER_ID -c name -f value)
	
	echo "$TEMP_VOLUME_NAME, $TEMP_VOLUME_ID, $TEMP_VOLUME_STATUS, \
	 $TEMP_VOLUME_SIZE, $TEMP_USER_ID, $TEMP_USER_INFO" >> ./1_4/volumes_table.csv
		
	done
echo -e "Step 1.4 is done, see file:\nvolumes_table.csv"
echo "================================================================================"
}

echo "================================================================================"


echo "================================================================================"
function get_nodes_info {
echo "================================================================================"
echo "Starting get info for hypervisors"
echo "Get hypervisor info..."

for (( i=1; i <= ${LIST_NODES}; i++ ))
	do

	TEMP_NODE=$(cat hypervisor_list.log | awk '{print $2}' | head -n ${i} | tail -n 1)
	GET_VCPUS=$(cat hypervisor_list.log | awk '{print $7}' | head -n ${i} | tail -n 1)
	GET_VCPUS_USED=$(cat hypervisor_list.log | awk '{print $6}' | head -n ${i} | tail -n 1)
	GET_MEMORY_MB=$(cat hypervisor_list.log | awk '{print $9}' | head -n ${i} | tail -n 1)
	GET_MEMORY_MB_USED=$(cat hypervisor_list.log | awk '{print $8}' | head -n ${i} | tail -n 1)

	RATIO_VCPUS=$(echo "scale=2; $GET_VCPUS_USED / $GET_VCPUS * 2" | bc -l | sed 's/^\./0\./') 
	RATIO_MEMORY=$(echo "scale=2; $GET_MEMORY_MB_USED / $GET_MEMORY_MB" | bc -l | sed 's/^\./0\./') 
	echo "For $TEMP_NODE RATIO_VCPUS = $RATIO_VCPUS AND RATIO_MEMORY = $RATIO_MEMORY"
	echo "$TEMP_NODE	$GET_VCPUS	$GET_VCPUS_USED   $GET_MEMORY_MB  $GET_MEMORY_MB_USED  $RATIO_VCPUS	$RATIO_MEMORY" >> ratio_info.log

	done
	
echo "sort ratio_info..."
cat ratio_info.log |  sort -k6 -k7 -g > ./2_3/ratio_info.log
echo -e "Step 2.3 is done, see files:\nratio_info.log"
}


function main {
	
echo "------------------------------------------------" # >> $LOGFILE 2>&1
echo "This RTO_INFO was started `date`" #>> $LOGFILE 2>&1
echo "------------------------------------------------"  #>> $LOGFILE 2>&1
echo "GET HYPERVISOR LIST INFO..."
openstack hypervisor list --long -f value > hypervisor_list.log
LIST_NODES=$(cat hypervisor_list.log | wc -l) 
echo "ALL NODES $LIST_NODES"
echo "GET INSTANCES LIST INFO..."
openstack server list --all --long > instances_list.log
LIST_INSTANCES=$(cat instances_list.log | wc -l)
echo "ALL INSTANCES $LIST_INSTANCES"
echo "Check folder..."

for (( i=0; i < ${#FOLDERS[@]}  ; i++ ))
do
	FOLDER_EXIST=$(ls -d */ | tr -d '/' | grep "${FOLDERS[ $i ]}" | wc -l)
	if [ "$FOLDER_EXIST" -eq "0" ]; then mkdir ${FOLDERS[ $i ]} && echo "create folder ${FOLDERS[ $i ]}";
	else
		echo "directory ${FOLDERS[ $i ]} already exists, files with previous results (expansion *.log) will be added to the prefix .old";
		for f in $(find ./${FOLDERS[ $i ]} -type f); do mv $f ${f}.old; done
	fi

done

	

get_instance_info
get_ports_info
get_security_group_info
get_volumes_info
get_nodes_info
}

main
exit 0;

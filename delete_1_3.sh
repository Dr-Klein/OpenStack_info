#! /bin/bash

LIST_IDS=$(cat sec_group_id.log | wc -l) 
echo "ALL SECURITY GROUPS $LIST_IDS"

for (( i=1; i <= ${LIST_IDS}; i++ ))
	do

	TEMP_SECGROUP_ID=$(cat sec_group_id.log | head -n ${i} | tail -n 1) 
	#debug echo "ID security group $i equal $TEMP_SECGROUP_ID"
	echo "Check status security group..."
	GET_PROJECT_ID=$(openstack security group show -c project_id -f value $TEMP_SECGROUP_ID)
	GET_PROJECT_STATUS=$(openstack project show $GET_PROJECT_ID 2>&1 | grep -oP "No project with a name or ID of" | wc -l  )
	if [ "$GET_PROJECT_STATUS" != "0" ]  
	then
		echo "This project does not exists for security group..."
		openstack security group delete $TEMP_SECGROUP_ID
		status=$?
	
		if [ $status -eq 0 ]   
		then
			echo "Delete succsess... [OK!]"
			echo "Security group with id: $TEMP_SECGROUP_ID was DELETED" >> list_deleted_sec_group.log
		else
		echo "Delete error!...Interrupt, see log file" >> sec_group_delete.log
		exit 1;
		fi	
	else
		echo "Project is EXIST! Continue..."
		echo "Security group is id: $TEMP_SECGROUP_ID not deleted! " >> list_other_status_sec_group.log
	fi
	done

exit 0;



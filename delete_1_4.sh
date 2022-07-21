#! /bin/bash

LIST_IDS=$(cat id_volumes.log | wc -l) 
echo "ALL VOLUMES $LIST_IDS"

for (( i=1; i <= ${LIST_IDS}; i++ ))
	do

	TEMP_VOLUME_ID=$(cat id_volumes.log | head -n ${i} | tail -n 1) 
	#debug echo "ID value number $i equal $TEMP_VALUE"
	echo "Check status volume"
	GET_STATUS=$(openstack volume show $TEMP_VOLUME_ID -c status -f value)
	if [ "$GET_STATUS" = "available" ]  
	then
		echo "Start delete process delete volume...."
		openstack volume delete $TEMP_VOLUME_ID
		status=$?
	
		if [ $status -eq 0 ]   
		then
			echo "Delete succsess... [OK!]"
			echo "Volume with id: $TEMP_VOLUME_ID was DELETED" >> list_deleted_volumes.log
		else
		echo "Delete error!...Interrupt, see log file" >> volume_delete.log
		exit 1;
		fi	
	else
		echo "Volume is status not available! It means or does not exist or in status in-use!"
		echo "Volume is id: $TEMP_VOLUME_ID is status $GET_STATUS" >> list_other_status_volumes.log
	fi
	done

exit 0;



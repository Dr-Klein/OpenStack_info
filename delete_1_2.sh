#! /bin/bash

LIST_IDS=$(cat id_interfaces.log | wc -l) 
echo "ALL INTERFACES $LIST_IDS"

for (( i=1; i <= ${LIST_IDS}; i++ ))
	do

	TEMP_PORT_ID=$(cat id_interfaces.log | head -n ${i} | tail -n 1) 
	#debug echo "ID value number $i equal $TEMP_VALUE"
	GET_STATUS=$(openstack port show $TEMP_PORT_ID -c status -f value)
	echo "Port ID: $TEMP_PORT_ID IS STATUS - $GET_STATUS " 
	if [ "$GET_STATUS" = "DOWN" ]   
	then
		#echo "Interfaces is id: $TEMP_PORT_ID  DOWN" >> list_down_ports.log
		echo "Start delete process network port...."
		openstack port delete $TEMP_PORT_ID
		status=$?

		if [ $status -eq 0 ]   
		then
			echo "Delete succsess... [OK!]"
			echo "Interfaces is id: $TEMP_PORT_ID was DELETED" >> list_deleted_ports.log
		else
		echo "Delete error!...Interrupt, please read the log file, bye" >> $LOGFILE 2>&1
		exit 1;
		fi	

	else
		echo "Port status is not DOWN! Continue..."
		echo "Interfaces is id: $TEMP_PORT_ID is status $GET_STATUS" >> list_active_ports.log
	fi
	done

exit 0;




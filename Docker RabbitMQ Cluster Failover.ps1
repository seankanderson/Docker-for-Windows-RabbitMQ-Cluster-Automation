CLEAR
Remove-Item z:\rabbitmq\MQBROKER_A_01 -Force -Recurse
Remove-Item z:\rabbitmq\MQBROKER_A_02 -Force -Recurse
Remove-Item z:\rabbitmq\MQBROKER_A_03 -Force -Recurse

docker cp MQBROKER_A_01:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_A_01
docker cp MQBROKER_A_02:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_A_02
docker cp MQBROKER_A_03:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_A_03

# Remove only files, leaving data directories
<#
Remove-Item z:\rabbitmq\MQBROKER_A_01\*.* | Where { ! $_.PSIsContainer }
Remove-Item z:\rabbitmq\MQBROKER_A_02\*.* | Where { ! $_.PSIsContainer }
Remove-Item z:\rabbitmq\MQBROKER_A_03\*.* | Where { ! $_.PSIsContainer }

docker exec -it MQBROKER_B_01 rabbitmqctl stop_app
docker exec -it MQBROKER_B_02 rabbitmqctl stop_app
docker exec -it MQBROKER_B_03 rabbitmqctl stop_app

docker exec -it MQBROKER_B_01 rabbitmqctl force_reset
docker exec -it MQBROKER_B_02 rabbitmqctl force_reset
docker exec -it MQBROKER_B_03 rabbitmqctl force_reset
#>


#Make a backup of passive node before configuring it to run as primary
<#
docker cp MQBROKER_B_01:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_B_01
docker cp MQBROKER_B_02:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_B_02
docker cp MQBROKER_B_03:/var/lib/rabbitmq z:\rabbitmq\MQBROKER_B_03
#>

#pump primary nodes' config data into passive nodes

docker exec -it MQBROKER_A_03 rabbitmqctl stop_app
docker exec -it MQBROKER_A_02 rabbitmqctl stop_app
docker exec -it MQBROKER_A_01 rabbitmqctl stop_app

<#
docker cp Z:\rabbitmq\MQBROKER_A_01\mnesia\rabbit@MQBROKER_A_01\msg_stores\vhosts MQBROKER_A_01:/var/lib/rabbitmq/mnesia/rabbit@MQBROKER_A_01/msg_stores/
docker cp Z:\rabbitmq\MQBROKER_A_02\mnesia\rabbit@MQBROKER_A_02\msg_stores MQBROKER_A_02:/var/lib/rabbitmq/mnesia/rabbit@MQBROKER_A_02
docker cp Z:\rabbitmq\MQBROKER_A_03\mnesia\rabbit@MQBROKER_A_03\msg_stores MQBROKER_A_03:/var/lib/rabbitmq/mnesia/rabbit@MQBROKER_A_03
#>

docker cp z:\rabbitmq\MQBROKER_A_01\config MQBROKER_A_01:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_01\mnesia MQBROKER_A_01:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_01\schema MQBROKER_A_01:/var/lib/rabbitmq

docker cp z:\rabbitmq\MQBROKER_A_02\config MQBROKER_A_02:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_02\mnesia MQBROKER_A_02:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_02\schema MQBROKER_A_02:/var/lib/rabbitmq

docker cp z:\rabbitmq\MQBROKER_A_03\config MQBROKER_A_03:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_03\mnesia MQBROKER_A_03:/var/lib/rabbitmq
docker cp z:\rabbitmq\MQBROKER_A_03\schema MQBROKER_A_03:/var/lib/rabbitmq


#make sure the rabbitmq process has permissions to the data directories
#using the docker cp command does not manage permissions 

docker exec -it MQBROKER_A_01 chown -R rabbitmq:rabbitmq /var/lib/rabbitmq 
docker exec -it MQBROKER_A_02 chown -R rabbitmq:rabbitmq /var/lib/rabbitmq 
docker exec -it MQBROKER_A_03 chown -R rabbitmq:rabbitmq /var/lib/rabbitmq 


docker exec -it MQBROKER_A_01 chmod -R 755 /var/lib/rabbitmq/config
docker exec -it MQBROKER_A_02 chmod -R 777 /var/lib/rabbitmq/mnesia 
docker exec -it MQBROKER_A_03 chmod -R 755 /var/lib/rabbitmq/schema 

docker exec -it MQBROKER_A_01 rabbitmqctl start_app
Start-Sleep 10
docker exec -it MQBROKER_A_02 rabbitmqctl start_app
Start-Sleep 10
docker exec -it MQBROKER_A_03 rabbitmqctl start_app

#TODO: change node names in rabbitmq database
<#
docker exec -it MQBROKER_B_01 rabbitmqctl rename_cluster_node `
rabbit@MQBROKER_A_01 rabbit@MQBROKER_B_01 `
rabbit@MQBROKER_A_02 rabbit@MQBROKER_B_02 `
rabbit@MQBROKER_A_03 rabbit@MQBROKER_B_03

docker exec -it MQBROKER_B_02 rabbitmqctl rename_cluster_node `
rabbit@MQBROKER_A_01 rabbit@MQBROKER_B_01 `
rabbit@MQBROKER_A_02 rabbit@MQBROKER_B_02 `
rabbit@MQBROKER_A_03 rabbit@MQBROKER_B_03

docker exec -it MQBROKER_B_03 rabbitmqctl rename_cluster_node `
rabbit@MQBROKER_A_01 rabbit@MQBROKER_B_01 `
rabbit@MQBROKER_A_02 rabbit@MQBROKER_B_02 `
rabbit@MQBROKER_A_03 rabbit@MQBROKER_B_03


docker exec -it MQBROKER_B_01 rabbitmqctl start_app
docker exec -it MQBROKER_B_02 rabbitmqctl start_app
docker exec -it MQBROKER_B_03 rabbitmqctl start_app

#>

#docker exec -it MQBROKER_A_01 ls -l /var/lib/rabbitmq

#docker exec -it MQBROKER_A_01 ls -l /var/lib/rabbitmq/mnesia/rabbit@MQBROKER_A_01

#docker exec -it MQBROKER_B_01 rm -rf /var/lib/rabbitmq/MQBROKER_A

#docker exec -it MQBROKER_A_01 rabbitmqctl eval 'ssl:cipher_suites().'


<#  RabbitMQ Failover Requirements

    Same service account for all rabbitmq instances
    Storage replication of RabbitMQ data folders



#>


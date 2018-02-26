
# Create additional IP addresses on your host NIC that is attached to the desired network.
# In this example I used $($cluster_subnet)30 as the address for the "main" rabbitmq node
# and used a little math to add host entries to each container pointing to the other nodes.
# Each rabbitmq container has a host entry for the other containers and the required ports 
# are mapped to the ip:port designated to each container.
# Each rabbitmq container/node can talk to the others via hostname and each host is reachable 
# on the "real" network at the addresses that were added to the host machine NIC.

$cluster = "D"
$cluster_ip = 51
$cluster_subnet = "192.168.2."
$cookie = "'dont_touch_my_cookie'"
$rabbitMqImage = "rabbitmq:3"

clear

if ($cluster -eq "A") 
{
    $alt_cluster = "B"
    $alt_ip = 51
}
if ($cluster -eq "B") 
{
    $alt_cluster = "A"
    $alt_ip = 41
}

if ($cluster -eq "C") 
{
    $alt_cluster = "D"
    $alt_ip = 51
}
if ($cluster -eq "D") 
{
    $alt_cluster = "C"
    $alt_ip = 41
}



#TODO: Use Autoheal?
#TODO: map rabbitmq data from node 1 to host folder
#TODO: export primary definitions after creating queues ??

#Disk Node Brokers
#TODO: Map drive
#-v /host/directory:/container/directory
docker run -d --hostname MQBROKER_$($cluster)_01 --name MQBROKER_$($cluster)_01 `
--add-host MQBROKER_$($cluster)_03:"$($cluster_subnet)$($cluster_ip+2)" `
--add-host MQBROKER_$($cluster)_02:"$($cluster_subnet)$($cluster_ip+1)" `
--add-host MQBROKER_$($alt_cluster):"$($cluster_subnet)$($alt_ip)" `
-p "$($cluster_subnet)$($cluster_ip):4369:4369" `
-p "$($cluster_subnet)$($cluster_ip):5671:5671" `
-p "$($cluster_subnet)$($cluster_ip):5672:5672" `
-p "$($cluster_subnet)$($cluster_ip):15671:15671" `
-p "$($cluster_subnet)$($cluster_ip):15672:15672" `
-p "$($cluster_subnet)$($cluster_ip):25672:25672" `
-e RABBITMQ_ERLANG_COOKIE=$cookie `
$rabbitMqImage



"waiting for ten seconds..."
Start-Sleep 5
docker exec -it MQBROKER_$($cluster)_01 rabbitmqctl stop_app

#TODO: Set environment variables of data locations
docker exec -it MQBROKER_$($cluster)_01 rabbitmq-plugins enable rabbitmq_shovel
docker exec -it MQBROKER_$($cluster)_01 rabbitmq-plugins enable rabbitmq_management
docker exec -it MQBROKER_$($cluster)_01 rabbitmq-plugins enable rabbitmq_federation
docker exec -it MQBROKER_$($cluster)_01 rabbitmq-plugins enable rabbitmq_federation_management

$cluster_ip++
docker run -d --hostname MQBROKER_$($cluster)_02 --name MQBROKER_$($cluster)_02 `
--add-host MQBROKER_$($cluster)_03:"$($cluster_subnet)$($cluster_ip+1)" `
--add-host MQBROKER_$($cluster)_01:"$($cluster_subnet)$($cluster_ip-1)" `
--add-host MQBROKER_$($alt_cluster):"$($cluster_subnet)$($alt_ip)" `
-p "$($cluster_subnet)$($cluster_ip):4369:4369" `
-p "$($cluster_subnet)$($cluster_ip):5671:5671" `
-p "$($cluster_subnet)$($cluster_ip):5672:5672" `
-p "$($cluster_subnet)$($cluster_ip):15671:15671" `
-p "$($cluster_subnet)$($cluster_ip):15672:15672" `
-p "$($cluster_subnet)$($cluster_ip):25672:25672" `
-e RABBITMQ_ERLANG_COOKIE=$cookie `
$rabbitMqImage

"waiting for ten seconds..."
Start-Sleep 5
docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl stop_app

#TODO: Set environment variables of data locations

docker exec -it MQBROKER_$($cluster)_02 rabbitmq-plugins enable rabbitmq_shovel
docker exec -it MQBROKER_$($cluster)_02 rabbitmq-plugins enable rabbitmq_management
docker exec -it MQBROKER_$($cluster)_02 rabbitmq-plugins enable rabbitmq_federation
docker exec -it MQBROKER_$($cluster)_02 rabbitmq-plugins enable rabbitmq_federation_management

$cluster_ip++
docker run -d --hostname MQBROKER_$($cluster)_03 --name MQBROKER_$($cluster)_03 `
--add-host MQBROKER_$($cluster)_02:"$($cluster_subnet)$($cluster_ip-1)" `
--add-host MQBROKER_$($cluster)_01:"$($cluster_subnet)$($cluster_ip-2)" `
--add-host MQBROKER_$($alt_cluster):"$($cluster_subnet)$($alt_ip)" `
-p "$($cluster_subnet)$($cluster_ip):4369:4369" `
-p "$($cluster_subnet)$($cluster_ip):5671:5671" `
-p "$($cluster_subnet)$($cluster_ip):5672:5672" `
-p "$($cluster_subnet)$($cluster_ip):15671:15671" `
-p "$($cluster_subnet)$($cluster_ip):15672:15672" `
-p "$($cluster_subnet)$($cluster_ip):25672:25672" `
-e RABBITMQ_ERLANG_COOKIE=$cookie `
$rabbitMqImage

"waiting for ten seconds..."
Start-Sleep 5
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl stop_app

#TODO: Set environment variables of data locations

docker exec -it MQBROKER_$($cluster)_03 rabbitmq-plugins enable rabbitmq_shovel
docker exec -it MQBROKER_$($cluster)_03 rabbitmq-plugins enable rabbitmq_management
docker exec -it MQBROKER_$($cluster)_03 rabbitmq-plugins enable rabbitmq_federation
docker exec -it MQBROKER_$($cluster)_03 rabbitmq-plugins enable rabbitmq_federation_management

"waiting for ten seconds..."
Start-Sleep 5

<# Create and start cluster #>
docker exec -it MQBROKER_$($cluster)_01 rabbitmqctl start_app

docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl stop_app
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl stop_app

docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl join_cluster rabbit@MQBROKER_$($cluster)_01
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl join_cluster rabbit@MQBROKER_$($cluster)_01

docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl start_app
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl start_app

#docker exec -it MQBROKER_A_01 rabbitmqctl eval 'rabbit_mnesia:dir().'


$cluster = "D"

docker exec -it MQBROKER_$($cluster)_01 rabbitmqctl start_app
docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl stop_app
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl stop_app

docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl join_cluster rabbit@MQBROKER_$($cluster)_01
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl join_cluster rabbit@MQBROKER_$($cluster)_01

docker exec -it MQBROKER_$($cluster)_02 rabbitmqctl start_app
docker exec -it MQBROKER_$($cluster)_03 rabbitmqctl start_app

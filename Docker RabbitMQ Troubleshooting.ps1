$server = "MQBROKER_B_02"
docker exec -it $server cat /var/lib/rabbitmq/mnesia/rabbit@$($server)/nodes_running_at_shutdown > "$($server)_nodes_running.json"

docker exec -it $server cat /var/log/rabbitmq/log/crash.log > "$($server)_crash.log"

docker exec -it $server cat /etc/rabbitmq/rabbitmq.conf > "$($server)_rabbitmq.conf"

<#
Cheat Sheet
Most commands are run on the cluster node you wish to affect.  
There are a few "remote" commands.


RABBITMQCTL
===============================================================

rabbitmqctl status
Dumps the current runtime information to the console.

rabbitmqctl -p / list_queues messages consumers

rabbitmqctl stop_app
Stops the RabbitMQ application.  Erlang process is still runnning.
Non-persistent messages are lost.

rabitmqctl reset
rabitmqctl force_reset
Leaves a cluster or otherwise resets a node's configuration to a virgin state.

rabbitmqctl start_app
Starts rabbitmq if the Erlang process is running.

rabbitmqctl shutdown
Stops rabbitmq and kills the Erlang process (node).
Non-persistant messages are lost.

crabbitmqctl join_cluster MyMasterNodeHostname
Creates or joins a cluster.  All messages on the joining node are lost.

rabbitmqctl sync_queue -p /MyVhost MyQueue01
Synchronizes a slave queue. 

rabbitmqctl cluster_status
Shows cluster details as seen from the node.

rabbitmqctl rename_cluster_node rabbit@currentNodeName rabbit@newNodeName
With the Erlang process shut down you can replace node names in a database. This is helpful for mounting a database from another cluster to serve its messages.

rabbitmqctl update_cluster_nodes rabbit@aClusterNode
Attaches to a node of the cluster from which it left that it may not have knowledge of.

rabbitmqctl force_boot
This will force the node not to wait for other nodes next time it is started. If you are considering this command you probably did not start the nodes in reverse order of shut down.

rabbitmqctl -n rabbit@liveNode forget_cluster_node rabbit@deadNode
Removes a node, remotely, from an online node's configuration. --offline can be used in cases where the last server to go down cannot be started and that node needs to be forgotten to get the cluster up.

Shows the supported cipers for TLS connections.
rabbitmqctl eval 'ssl:cipher_suites().'




#>
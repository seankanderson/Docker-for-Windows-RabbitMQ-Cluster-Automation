
docker exec -it MQBROKER_A_02 rabbitmqctl stop_app
docker exec -it MQBROKER_B_02 rabbitmqctl stop_app

docker exec -it MQBROKER_A_02 rabbitmqctl start_app
docker exec -it MQBROKER_B_02 rabbitmqctl start_app

#primary cluster
#secondary unconfigured cluster

# stop primary node (failure or graceful)
# ensure that primary VMs are shut down or without access to data
# change environment variables of passive nodes to point to failed nodes' data
# rename the nodes in the primary database to reflect the passive node names
# import definitions into passive nodes
# start passive cluster



<#

    Failover Testing Sequence:
    Create primary cluster
    Create secondary cluster
    Publish messages (several hundred thousand)
    Consume messages (several thousand)
    Kill primary abruptly before most messages ar consumed
    Bring up secondary
    Import definitions of primary?
    Rename nodes in data to match secondary names
    Bring up secondary cluster

    Secondary cluster should come up and be able to serve messages to consumers
    Need LB to handle failover
#>

<#

    Maintenance Test Sequence
    Create primary cluster
    Create secondary cluster
    Federate clusters (bi-directional)
    Start publishers and consumers on primary
    Accumulate serious message backlog
    Switch cluster DNS to point to secondary
    (observe behavior)

    Publishers and consumers should start acting against the secondary
    Primary should be drained

#>


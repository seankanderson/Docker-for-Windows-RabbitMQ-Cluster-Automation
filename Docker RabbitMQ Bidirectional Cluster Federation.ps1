clear

Function RestPut($URL, $JSON){
    $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($JSON);
    $URI = [System.Uri]$([string]$URL);
    $WebRequest = [System.Net.HttpWebRequest]::Create($URI);
    $webRequest.Headers.Add("Authorization", "Basic Z3Vlc3Q6Z3Vlc3Q=");
    $WebRequest.Method = 'PUT';
    $WebRequest.ContentType = 'application/json';
    $WebRequest.GetRequestStream().Write($BodyBytes, 0, $BodyBytes.Length);
    $WebRequest.GetResponse()
    $resp = $WebRequest.GetResponse();
    [int]$resp.StatusCode   
}

<#
docker exec -it MQBROKER_A_XX cat /etc/hosts
192.168.0.30 MQBROKER_A_01
192.168.0.31 MQBROKER_A_02
192.168.0.32 MQBROKER_A_03
192.168.0.33 MQBROKER_A
192.168.0.50 MQBROKER_B_01
192.168.0.51 MQBROKER_B_02
192.168.0.52 MQBROKER_B_03
192.168.0.53 MQBROKER_B
#>

<# Expected response code is 201. 204 means your policy most likely already exists #>
<# Create upstream federations for each cluster #>
$url = "http://MQBROKER_B:15672/api/parameters/federation-upstream/%2f/my-upstream"

$policy = '{"value":{"uri":"amqp://MQBROKER_A","expires":3600000}}'

RestPut $url $policy

$url = "http://MQBROKER_A:15672/api/parameters/federation-upstream/%2f/my-upstream"

$policy = '{"value":{"uri":"amqp://MQBROKER_B","expires":3600000}}'

RestPut $url $policy


<# Set THE policy -- only one policy is in force on a resource at any one time#>
$url = "http://MQBROKER_B:15672/api/policies/%2f/federate-me"

$policy = '{"pattern":".*", "definition":{"federation-upstream-set":"all", "ha-mode": "all"}, "apply-to":"all"}'

RestPut $url $policy

$url = "http://MQBROKER_A:15672/api/policies/%2f/federate-me"

$policy = '{"pattern":".*", "definition":{"federation-upstream-set":"all", "ha-mode": "all"}, "apply-to":"all"}'

RestPut $url $policy

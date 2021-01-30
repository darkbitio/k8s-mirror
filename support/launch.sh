#!/bin/bash

rc-status
touch /run/openrc/softlevel
rc-service etcd start
/load.rb /data/import.json
kube-apiserver --etcd-servers http://127.0.0.1:2379 --insecure-bind-address=0.0.0.0 --insecure-port=8080 --allow-privileged=true --authorization-mode=Node,RBAC --anonymous-auth=false --token-auth-file=/tokens.txt -v=0 --storage-media-type=application/json

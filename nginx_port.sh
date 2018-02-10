#!/bin/sh
echo "Create a nginx with 2 replicas (pods)"
kubectl run myweb --replicas=2 --image=nginx:alpine  --port=80 --expose=true

#kubectl expose deploy myweb --type=LoadBalancer --name=nginxbalancer --port=80 --target-port=8000

sleep 5
printf "service exposed at : %s\n" $(minikube service nginxbalancer --url)
curl $(minikube service nginxbalancer --url)
printf "\n"
sleep 5
echo "Delete service and deployment"
#kubectl delete service nginxbalancer
#kubectl delete deployment myweb
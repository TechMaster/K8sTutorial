#!/bin/sh
echo "Create a nginx with 2 replicas (pods)"
kubectl run myweb --replicas=2 --image=nginx:alpine  --port=80

kubectl expose deployment myweb --type=LoadBalancer --name=nginxbalancer

sleep 5
printf "service exposed at : %s\n" $(minikube service nginxbalancer --url)
curl $(minikube service nginxbalancer --url)
printf "\n"
sleep 5
echo "Delete service and deployment"
kubectl delete service nginxbalancer
kubectl delete deployment myweb
#!/bin/sh
echo "Create a helloworld with 5 replicas (pods)"
kubectl run hello-world --replicas=5 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
kubectl get deployments hello-world
kubectl describe deployments hello-world

kubectl get replicasets
kubectl describe replicasets
kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
kubectl get services my-service
kubectl describe services my-service
kubectl get pods --output=wide
sleep 5
echo 
curl $(minikube service my-service --url)
printf "\n"
sleep 5
echo "Delete service and deployment"
kubectl delete service my-service
kubectl delete deployment hello-world
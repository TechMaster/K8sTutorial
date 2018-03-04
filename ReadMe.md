
# Bai 1 : Cài đặt minikube
minikube tạo ra local cluster
## Cài đặt minikube trên MacOSX
## Cài đặt minikube trên Linux Ubuntu

## Gỡ bỏ minikube

## Xử lý lỗi khi khởi động minikube

# Bài 2: Khởi động minikube
$ minikube start --vm-driver=virtualbox
Starting local Kubernetes v1.9.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.

$ minikube version
minikube version: v0.25.0

$ minikube dashboard

# Bài 3: Chạy alpine ở chế độ interactive terminal
```
$ kubectl run alpine --image=alpine:latest --restart=Never -it
$ kubectl run busybox --image=busybox --restart=Never -it
```

# Bài 4: Ứng dụng helloworld
Ứng dụng này in ra dòng chữ Hello Kubernetes! sau đó dọn dẹp, xoá deployment và service vừa tạo ra
```
$ ./helloworld.sh
```
# Bài 5: Chạy load balancer service nối vào 2 Nginx replica
```
$ ./nginx.sh
```
Chú ý lệnh sẽ lấy địa chỉ truy cập vào service
```
$ minikube service nginxbalancer --url
```
# Bài 6: Tạo một pod đơn giản
Định nghĩa pod-nginx.yaml như sau
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
```
Tạo pod nginx
```
$ kubectl create -f pod-nginx.yaml
```
## 6.1 Lấy địa chỉ IP của pod
Lấy danh sách chi tiết các pod
```
$ kubectl get pod -o wide
```
hoặc để lấy địa chỉ IP
```
$ kubectl get pod nginx -o go-template='{{.status.podIP}}'
172.17.0.11
```
Dùng lệnh describe để lấy thông tin chi tiết một pods
```
$ kubectl describe pod nginx | grep IP:
IP:           172.17.0.11
```
Sau đó khởi động một pod khác ở chế độ interactive terminal kết nối vào pod đang chạy
```
$ kubectl run -i -t alpine --image=alpine:latest --restart=Never
```
trong dòng lệnh bên trong alpine, gõ
```
$ wget -qO- http://ip_adress of nginx pod
```

Cách thứ 2 theo hướng dẫn
```
$ kubectl run busybox --image=busybox --restart=Never --tty -i --generator=run-pod/v1 --env "POD_IP=$(kubectl get pod nginx -o go-template='{{.status.podIP}}')"
u@busybox$ wget -qO- http://$POD_IP # Run in the busybox container
u@busybox$ exit # Exit the busybox container
$ kubectl delete pod busybox # Clean up the pod we created with "kubectl run"
```
# Bài 7: Kết nối vào pod đang chạy
Kết nối vào trong pod nginx thông qua terminal. Nếu pod có nhiều hơn một container, cần bổ xung option -c
Lệnh này giống với docker exec
```
kubectl exec nginx -c nginx -it -- sh
```
## Xoá nhiều deployment cùng một lúc
```
kubectl delete deployment nginx webby my-nginx
```

# Bài 8: Sử dụng Replication Controller
Replication Controller dùng để vận hành nhóm các Pod chạy trong thời gian dài. Nếu RC phát hiện Pod nào bị lỗi, bị tắt, dừng, RC sẽ tạo ra Pod mới thay thế.

[rc_caddy.yaml](rc_caddy.yaml)

Chạy lệnh sau đây
```
$ kubectl create -f rc_caddy.yaml
$ kubectl get rc
$ kubectl get pod
NAME            READY     STATUS    RESTARTS   AGE
rccaddy-dmvgs   1/1       Running   0          6m
rccaddy-g2dnb   1/1       Running   1          2h
rccaddy-v8gzr   1/1       Running   1          3h
$ kubectl delete pod rccaddy-dmvgs
```
Hãy quan sát pod mới được tạo lại bằng cách liên tục gõ lệnh ```kubectl get pod```
Xem label các pod
```
$ kubectl get pod --show-labels
NAME            READY     STATUS    RESTARTS   AGE       LABELS
rccaddy-g2dnb   1/1       Running   3          16h       app=caddyweb
rccaddy-ll6h9   1/1       Running   0          22m       app=caddyweb
```
## Mở rộng hay thu nhỏ số lượng pod đồng dạng (replicas) trong một replica controllers
```
$ kubectl get rc
NAME      DESIRED   CURRENT   READY     AGE
rccaddy   3         3         2         16h

$ kubectl get pod                                            
NAME            READY     STATUS    RESTARTS   AGE
rccaddy-g2dnb   1/1       Running   3          16h
rccaddy-ll6h9   1/1       Running   0          18m
rccaddy-v8gzr   1/1       Running   3          16h

$ kubectl scale --replicas=5 rc/rccaddy
$ kubectl get pod
NAME            READY     STATUS    RESTARTS   AGE
rccaddy-g2dnb   1/1       Running   3          16h
rccaddy-l5s9z   1/1       Running   0          26s
rccaddy-ll6h9   1/1       Running   0          19m
rccaddy-rrfjj   1/1       Running   0          26s
rccaddy-v8gzr   1/1       Running   3          17h

$ kubectl scale --replicas=2 rc/rccaddy
NAME            READY     STATUS    RESTARTS   AGE
rccaddy-g2dnb   1/1       Running   3          16h
rccaddy-ll6h9   1/1       Running   0          20m
```
Xoá replica controller
```
$ kubectl delete rc rccaddy
replicationcontroller "rccaddy" deleted

$ kubectl get rc
No resources found.
```

# Bài 9: Deployment - Service 
[nginx-app.yaml](nginx-app.yaml) là file định nghĩa service và deployment tương tự như docker-compose.yml

Hiểu rõ hơn về deployment xem ở đây:
- [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubernetesbyexample.com/deployment](http://kubernetesbyexample.com/deployments/)

Khác biệt giữa Replica Set và Replica Controller. Replica Set hỗ trợ selector
```
$ kubectl create -f nginx-app.yaml
service "my-nginx-svc" created
deployment "my-nginx" created

$ kubectl get deploy
NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-nginx   3         3         3            3           10h

$ kubectl get rs
NAME                 DESIRED   CURRENT   READY     AGE
my-nginx-b477df957   3         3         3         3m

$ kubectl describe rs my-nginx-b477df957
```
## Kết nối vào load balance service
```
$ minikube service my-nginx-svc --url
http://192.168.99.100:32496
$ curl http://192.168.99.100:32496
$ curl (minikube service my-nginx-svc --url)
```

## Nối vào một pod
Lệnh này tương đối giống ```docker exec container_name -it /bin/sh```
```
$ kubectl get pod
NAME                       READY     STATUS    RESTARTS   AGE
my-nginx-b477df957-25wcp   1/1       Running   1          11h
my-nginx-b477df957-6wn7f   1/1       Running   1          11h
my-nginx-b477df957-rsj8n   1/1       Running   1          11h

$ kubectl exec my-nginx-b477df957-25wcp -it /bin/sh  
/ # uname -a
Linux my-nginx-b477df957-25wcp 4.9.64 #1...
```

## 9.1: Kết nối vào service cluster IP
```
$ kubectl get service
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP      10.96.0.1        <none>        443/TCP        4d
my-nginx-svc   LoadBalancer   10.105.132.254   <pending>     80:32496/TCP   2d
```
Không thể ping địa chỉ Cluster-IP, 10.105.132.254 của my-nginx-svc, do đó ta cần vào một pod trong cluster
thì mới truy cập được service này. Chú ý truy cập ở cổng 80
```
$ kubectl exec my-nginx-b477df957-25wcp -it /bin/sh
$ wget -qO- http://10.105.132.254
```

## 9.2 Kết nối qua Node Port
Ở trường hợp này, chúng ta không cần vào trong pod mà ở ngoài Mac, tuy nhiên cổng truy cập sẽ không phải là 80 mà 32496
```
$ mk service my-nginx-svc --url
http://192.168.99.100:32496

$ curl http://192.168.99.100:32496
```
## 9.3 port forwarding để nối vào một pod cụ thể trong cluster
1. Lấy tên các pod trong cluster
2. Chọn ra một pod để forward cổng từ host vào cổng container trong pod đó phục vụ 
```
$ kubectl get pod
$ sudo kubectl port-forward myweb-5487d54c5-2g2p7 80:80
```

# Bài 10: Tạo ingress controller
[Kubernetes Webinar Series - Everything About Ingress](https://www.youtube.com/watch?v=HwogE64wjmw)
```
$ kubectl create -f ingress.yaml
ingress "ingress-nginx" created

$ kubectl get ing
NAME            HOSTS     ADDRESS          PORTS     AGE
ingress-nginx   *         192.168.99.100   80        12s

$ curl http://192.168.99.100
```

Tìm hiểu thêm về ingress controller
```
$ kubectl describe ing ingress-nginx
Name:             ingress-nginx
Namespace:        default
Address:          192.168.99.100
Default backend:  my-nginx-svc:80 (172.17.0.3:80,172.17.0.4:80,172.17.0.5:80)
Rules:
  Host  Path  Backends
  ----  ----  --------
  *     *     my-nginx-svc:80 (172.17.0.3:80,172.17.0.4:80,172.17.0.5:80)
Annotations:
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  CREATE  6m    nginx-ingress-controller  Ingress default/ingress-nginx
  Normal  UPDATE  5m    nginx-ingress-controller  Ingress default/ingress-nginx
```

# Bài 11: Trao đổi giữa hai container trong cùng 1 pod thông qua Shared Volume
[Communicate Between Containers in the Same Pod Using a Shared Volume](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/)

Tham khảo file [two-container-pod.yaml](two-container-pod.yaml)
```
$ kubectl create -f two-container-pod.yaml
pod "two-containers" created

$ kubectl exec -it two-containers -c nginx-container -- /bin/sh

/ # hostname
two-containers
/ # wget -qO- localhost
Hello from the debian container
```

## 11.1 Thực hành nâng cao
hay thử thay args trong nginx-container
```
args: ["-c", "echo Hello from the debian container > /pod-data/index.html"]
# bằng dòng này
args: ["-c", "while true; do echo hello >> /pod-data/index.html; sleep 10;done"]
```

# Bài 12: Convert Docker-Compose sang K8s
Sử dụng Kompose.io

# Bài 13: Chọn giải pháp phù hợp cài đặt Kubernetes
[Tài liệu chọn giải pháp cài đặt K8s](https://kubernetes.io/docs/setup/pick-right-solution/)

# Bài 14: Đóng gói ứng dụng Node.js vào K8s
[Tham khảo](https://seanmcgary.com/posts/how-to-deploy-a-nodejs-app-to-kubernetes/)

1. Hãy vào thu mục [nodeapp](nodeapp/)
2. Tạo Node.js app, xem file [nodeapp/index.js](nodeapp/index.js)
```
npm init
yarn add express
node index.js
curl http://localhost:3000
```
2. Tạo file shell script để tự động hoá việc build docker image và kiểm thử.
Xem file [nodeapp/build.sh](nodeapp/build.sh)

```
$ kubectl create -f node_app_service.yaml
service "node-app-service" created

$ kubectl get service
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes         ClusterIP      10.96.0.1        <none>        443/TCP          16d
my-nginx-svc       LoadBalancer   10.105.132.254   <pending>     80:32496/TCP     14d
node-app-service   LoadBalancer   10.105.244.118   <pending>     3000:32282/TCP   8s

$ minikube service node-app-service --url
http://192.168.99.100:32282

$ curl http://192.168.99.100:32282
```

# Bài 15: Cài đặt K8s trên Google Cloud Platform sử dụng GKE (Google Kubernetes Engine)
https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app
Commands:

Step 0: Before you begin
    - gcloud components install kubectl

Step 1: Build the container image
    - git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples
    - cd kubernetes-engine-samples/hello-app
    - export PROJECT_ID="$(gcloud config get-value project -q)"

    # Build Docker App and push to a Container Registry
    - docker build -t gcr.io/${PROJECT_ID}/hello-app:v1 .

    # Check
    - docker images

Step 2: Upload the container image
    - gcloud docker -- push gcr.io/${PROJECT_ID}/hello-app:v1

Step 4: Create a container cluster
    - gcloud container clusters create hello-cluster --num-nodes=3
    - gcloud compute instances list

Step 5: Deploy your application
    - kubectl run hello-web --image=gcr.io/${PROJECT_ID}/hello-app:v1 --port 8080
    - kubectl get pods

Step 6: Expose your application to the Internet
    - kubectl expose deployment hello-web --type=LoadBalancer --port 80 --target-port 8080

    # Checking launching service (take awhile to get external IP assigned)
    kubectl get service

Step 7: Scale up your application
    - kubectl scale deployment hello-web --replicas=3
    - kubectl get deployment hello-web
    - kubectl get pods

Step 8: Deploy a new version of your app
    - docker build -t gcr.io/${PROJECT_ID}/hello-app:v2 .
    - gcloud docker -- push gcr.io/${PROJECT_ID}/hello-app:v2
    - kubectl set image deployment/hello-web hello-web=gcr.io/${PROJECT_ID}/hello-app:v2

Cleaning up
    kubectl delete service hello-web
    gcloud compute forwarding-rules list
    gcloud container clusters delete hello-cluster
    
# Bài 16: K8s trên Amazon Web ServicesServices
1. Tạo tài khoản Amazon Web Service. [Link đây](https://portal.aws.amazon.com/billing/signup#/start)
2. 

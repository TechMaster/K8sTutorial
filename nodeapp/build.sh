#!/bin/sh
CONTAINER_NAME="nodeapp"
PORT="3000"
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker build -t $CONTAINER_NAME:latest .
docker run --name nodeapp -d -p $PORT:$PORT nodeapp
sleep 1
# Kiểm tra kết quả trả về
if [ "test ok" == "$(curl http://localhost:3000/test)" ]
then
  echo "Docker container works"
  # Push docker image to docker hub
  docker tag $CONTAINER_NAME:latest minhcuong/$CONTAINER_NAME
  docker push minhcuong/$CONTAINER_NAME:latest
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  echo "Done"
fi
#!/bin/bash

source ./set-env.sh

echo "Creating new cluster '${CLUSTER}'..."
gcloud container clusters create "${CLUSTER}" --zone "${ZONE}" --num-nodes=4
# Set auth on kubectl
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"

echo "Creating external IP addresses"
gcloud compute addresses create keycloak-global-ip --global
gcloud compute addresses create portal-global-ip --global
export KEYCLOAK_IP=`gcloud compute addresses describe keycloak-global-ip --global --format='get(address)'`
export PORTAL_IP=`gcloud compute addresses describe portal-global-ip --global --format='get(address)'`

echo "Deploying Redis..."
# Possible parameters: https://github.com/helm/charts/tree/master/stable/redis
helm install redis \
  --set usePassword=false \
    bitnami/redis

echo "Deploying RabbitMQ with AMQP 1.0 plugin..."
# Possible parameters: https://github.com/helm/charts/tree/master/stable/rabbitmq
helm install rabbitmq-amqp10 \
  --set replicas=2,rabbitmq.username=${RABBITMQ_USER},rabbitmq.password=${RABBITMQ_PASSWORD},rabbitmq.plugins="rabbitmq_management rabbitmq_peer_discovery_k8s rabbitmq_amqp1_0" \
    bitnami/rabbitmq

echo "Deploying MongoDB"
# Possible parameters: https://github.com/helm/charts/tree/master/stable/mongodb
helm install mongodb \
  --set replicaSet.enabled=true,mongodbDatabase=${MONGODB_DATABASE},mongodbUsername=${MONGODB_USER},mongodbPassword=${MONGODB_PASSWORD} \
    bitnami/mongodb

echo "Deploying MySQL"
# Possible parameters: https://github.com/helm/charts/tree/master/stable/mongodb
helm install mysql \
  --set replicaSet.enabled=true,mysqlDatabase=${MYSQL_DATABASE},mysqlUser=${MYSQL_USER},mysqlPassword=${MYSQL_PASSWORD} \
    stable/mysql

echo "Deploying Keycloak"
# Possible parameters: https://github.com/codecentric/helm-charts/tree/master/charts/keycloak
helm install keycloak \
  -f keycloak/values.yaml \
  --set keycloak.persistence.dbName=${MYSQL_DATABASE},keycloak.persistence.dbUser=${MYSQL_USER},keycloak.persistence.dbPassword=${MYSQL_PASSWORD},\
keycloak.persistence.dbHost=mysql.default,keycloak.persistence.dbPort=3306,keycloak.username=${KEYCLOAK_ADMIN_USER},keycloak.password=${KEYCLOAK_ADMIN_PASSWORD} \
  codecentric/keycloak
kubectl apply -f ./keycloak/keycloak-ingress.yaml

echo "Creating ConfigMap with platform services..."
echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: platform-services
  namespace: default
data:
  REDIS_HOST: redis-master.default
  REDIS_PORT: '6379'
  RABBITMQ_HOST: rabbitmq-amqp10.default
  RABBITMQ_PORT: '5672'
  RABBITMQ_USER: $RABBITMQ_USER
  MONGODB_CONNECTION_URI: mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@mongodb-primary-0.mongodb-headless.default:27017,mongodb-secondary-0.mongodb-headless.default:27017/${MONGODB_DATABASE}?replicaSet=rs0
  KEYCLOAK_URL: http://${KEYCLOAK_IP}" \
  | kubectl apply -f -

echo "Successfully setup cluster!"

echo "Keycloak is available at http://${KEYCLOAK_IP}"
echo "The Mashroom Portal will be available at http://${PORTAL_IP}"

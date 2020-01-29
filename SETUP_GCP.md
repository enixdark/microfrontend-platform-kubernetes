
# Setup on Google Kubernetes Engine

## Requirements

Create a [GCP](https://cloud.google.com/) account and:

 * Create a new project
 * Enable Kubernetes Engine
 * Enable Filestore API

Then install locally:

 * [gcloud](https://cloud.google.com/sdk)
 * kubectl (gcloud components install kubectl)
 * [docker](https://www.docker.com)
 * [helm](https://helm.sh/)

And add at least the following Helm repos:

    helm repo add stable https://kubernetes-charts.storage.googleapis.com/

Init the gcloud CLI:

    gcloud init

##  Adapt the environment variables

Edit **set-env.sh** according to your GCP settings and needs.

At very least you should set:

 * *PROJECT_ID* -> this is the Project ID in GCP
 * *ZONE* -> The zone in which the cluster should be created (this also affects the billing)

## Run the setup cluster script

    ./setup-cluster.sh

## Deploy the Mashroom Portal

    cd portal
    npm run deploy

## Deploy the Microfrontends

     cd microfrontend-demo1
     npm run deploy
     cd ..
     cd microfrontend-demo2
     npm run deploy

## Check if the platform is up and running

 * Open the GCP console and navigate to Kubernetes Engine -> Worksloads. You
   should see something like this:

 TODO:


 * Enter http://<ingress-ip> in your browser
 * Login as admin/admin
 * On an arbitrary page click *Add App*, search for *Microfrontend Demo1* and add via Drag'n'Drop:
   ![Microfrontends](./images/microfrontends.png)
 * You can check the registered Microfrontends on http://<ingress-ip>/portal-remote-app-registry-kubernetes
   ![Kubernetes Services](./images/registered_k8s_services.png)
 * To check the messaging add the *Mashroom Portal Demo Remote Messaging App* (as admin) to a page,
   open the same page as another user (john/john) and send as *john* a message to *user/admin/test* -
   it should appear in the other users *Demo Remote Messaging App*
 * You can also check if all portal replicas are subscribed to the message broker. The RabbitMQ Admin UI can
   be made locally available with:

        kubectl port-forward --namespace default svc/rabbitmq-amqp10 15672:15672

   After opening http://localhost:15672 and logging in you should be able to see the bindings on the *amqp.topic* exchange:
   ![The platform](./images/rabbitmq_bindings.png)
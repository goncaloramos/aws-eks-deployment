#!/bin/bash

#config kubectl context:
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

#create namespace:
kubectl create namespace eks-sample-app

#----

#Create an AWS Identity and Access Management (IAM) 
#OIDC provider and associate the OIDC provider with your cluster
eksctl utils associate-iam-oidc-provider --region $(terraform output -raw region) --cluster $(terraform output -raw cluster_name) --approve

#Download an IAM policy for the AWS Load Balancer Controller
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json

#Create an IAM policy using the policy that you downloaded
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

#Create an IAM role for the AWS Load Balancer Controller and attach the role to the service account
eksctl create iamserviceaccount --cluster=$(terraform output -raw cluster_name) --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::878598450595:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve



#Apply deployment manifest to eks cluster:
#kubectl apply -f eks-sample-deployment.yaml

#Apply Service manifest to eks cluster:
#kubectl apply -f eks-sample-service.yaml

#View all resources existing in th eks-sample-app namespace:
#kubectl get all -n eks-sample-app

#View the details of the deployed Service
#kubectl -n eks-sample-app describe service eks-sample-linux-service

#View details of one pod listed in the namespace output
#kubectl -n eks-sample-app describe pod [pod-name]

#ssh into one pod
#kubectl exec -it [pod-name] -n eks-sample-app -- /bin/bash

#View output from the web served installed with the deployment
#curl eks-sample-linux-service

#Remove the sample Namespace, Service, and Deployment
#kubectl delete namespace eks-sample-app

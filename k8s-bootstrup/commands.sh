# configure kubectl context with AWS EKS
$ aws eks update-kubeconfig --name <eks_cluster_name>
# install Ingress Controller
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
$ git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.2.0
$ cd kubernetes-ingress/deployments
$ kubectl apply -f common/ns-and-sa.yaml
$ kubectl apply -f rbac/rbac.yaml
$ kubectl apply -f common/default-server-secret.yaml
$ kubectl apply -f common/nginx-config.yaml
$ kubectl apply -f common/ingress-class.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
$ kubectl apply -f deployment/nginx-ingress.yaml
$ kubectl get pods --namespace=nginx-ingress
$ kubectl describe svc nginx-ingress --namespace=nginx-ingress
$ kubectl apply -f service/loadbalancer-aws-elb.yaml
# update nginx-config.yaml with data:
#    proxy-protocol: "True"
#    real-ip-header: "proxy_protocol"
#    set-real-ip-from: "0.0.0.0/0"
$ kubectl apply -f common/nginx-config.yaml
$ kubectl get svc --namespace=nginx-ingress
#test
$ cd test-app/
$ kubectl apply -f deployments/
$ curl -I ae57fcc4d328a4bf7bdd2cbe0e1bf225-1167643887.us-east-1.elb.amazonaws.com/
> 403
$ curl -I -H "Host: hostname.mydomain.com" ae57fcc4d328a4bf7bdd2cbe0e1bf225-1167643887.us-east-1.elb.amazonaws.com/
>200


# install HELM
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
# install Jenkins
$ helm repo add jenkinsci https://charts.jenkins.io
$ helm repo update
$ helm search repo jenkinsci
$ kubectl create namespace jenkins
# create PV for jenkins at K8s
$ kubectl apply -f ./deployments/jenkins-volume.yaml
# create a service account
$ kubectl apply -f ./deployments/jenkins-sa.yaml
# create ingress resourse rule (get the DNS name (kubectl get svc --namespace=nginx-ingre) and put it to host)
# spec:
#  rules:
#    - host: "ae57fcc4d328a4bf7bdd2cbe0e1bf225-1167643887.us-east-1.elb.amazonaws.com"
$ kubectl apply -f ./deployments/ingress.yaml
$ chart=jenkinsci/jenkins
$ helm install jenkins -n jenkins -f jenkins-values.yaml $chart
# Get your 'admin' user password
$ jsonpath="{.data.jenkins-admin-password}"
$ secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
$ echo $(echo $secret | base64 --decode) ### yRAgolZjqgl30wSld4uI7Y
# Get endpoint
$ kubectl get svc --namespace=nginx-ingress
# login here - http://ae57fcc4d328a4bf7bdd2cbe0e1bf225-1167643887.us-east-1.elb.amazonaws.com/login

# configure kubectl context with AWS EKS
$ aws eks update-kubeconfig --name eks_cluster


# install Ingress Controller
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
$ git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.2.0
$ cd k8s-bootstrup/kubernetes-ingress/deployments
$ kubectl apply -f common/ns-and-sa.yaml
$ kubectl apply -f rbac/rbac.yaml
$ kubectl apply -f common/default-server-secret.yaml
# update nginx-config.yaml with data:
#    proxy-protocol: "True"
#    real-ip-header: "proxy_protocol"
#    set-real-ip-from: "0.0.0.0/0"
$ kubectl apply -f common/nginx-config.yaml
$ kubectl apply -f common/ingress-class.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
$ kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
$ kubectl apply -f deployment/nginx-ingress.yaml
$ kubectl apply -f service/loadbalancer-aws-elb.yaml
#test
$ cd test-app/
$ kubectl apply -f deployments/
$ kubectl get svc --namespace=nginx-ingress
$ curl -I a8d2f493eeed745928e034b6207ae6b8-941044987.us-east-1.elb.amazonaws.com/
> 403
$ curl -I -H "Host: hostname.mydomain.com" a8d2f493eeed745928e034b6207ae6b8-941044987.us-east-1.elb.amazonaws.com/testapp
>200


# install HELM
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh


# configure AWS EFS K8S PV
#(https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/)
$ kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
$ cd aws-efs-pv/deployments/
$ kubectl apply -f efs-sc.yaml -f persistentvolume.yaml -f efs-claim.yaml


# install Jenkins
$ helm repo add jenkins https://charts.jenkins.io
$ helm repo update
$ helm install jenkins jenkins/jenkins --set rbac.create=true,controller.servicePort=80,controller.serviceType=LoadBalancer,persistence.existingClaim=efs-claim
$ printf $(kubectl get service jenkins -o jsonpath="{.status.loadBalancer.ingress[].hostname}");echo
# > a0540f4e8513043008da22d409608bd4-1458100344.us-east-1.elb.amazonaws.com
$ printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
# > k0VuPgkfXstsZQ6u1dYL7q







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

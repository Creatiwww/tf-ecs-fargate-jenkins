# Jenkins on AWS EKS cluster with Terraform and Helm

## How to run:

#### deploy AWS infra with Terraform
```
$ cd tf-eks-jenkins/tf/environments/playground
$ terraform init
$ terraform apply
```

#### configure kubectl context with AWS EKS
```
$ aws eks update-kubeconfig --name eks_cluster
```

#### install Ingress on created cluster
```
(https://aws.amazon.com/premiumsupport/knowledge-center/eks-access-kubernetes-services/)
(https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/)
$ helm install helm/charts/nginx-ingress my_ingress
```

#### configure PV and PVC
```
(https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/)
$ kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
# copy-paste from AWS EFS console value for "volumeHandle' @helm/charts/aws-efs-pv/values.yaml
$ helm install pv-pvc helm/charts/aws-efs-pv
```

#### install Jenkins
```
$ helm repo add jenkins https://charts.jenkins.io
$ helm repo update
$ helm install jenkins jenkins/jenkins --set rbac.create=true,controller.servicePort=80,controller.serviceType=LoadBalancer,persistence.existingClaim=efs-claim
$ printf $(kubectl get service jenkins -o jsonpath="{.status.loadBalancer.ingress[].hostname}");echo
# > a66d518269ca3460ca2205ee8382f7d8-1912011121.us-east-1.elb.amazonaws.com
$ printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
# > UJFuKBDyeqBpyv0rYCimP9
```


## Prerequisites:

#### install HELM
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

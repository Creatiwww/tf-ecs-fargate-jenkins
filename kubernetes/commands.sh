# install Ingress
$ helm install nginx-ingress my_ingress

# configure PV and PVC
$ kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
# copy-paste from AWS EFS console value for "volumeHandle' @kubernetes/charts/aws-efs-pv/values.yaml
$ helm install pv-pvc aws-efs-pv

# install Jenkins
$ helm repo add jenkins https://charts.jenkins.io
$ helm repo update
$ helm install jenkins jenkins/jenkins --set rbac.create=true,controller.servicePort=80,controller.serviceType=LoadBalancer,persistence.existingClaim=efs-claim
$ printf $(kubectl get service jenkins -o jsonpath="{.status.loadBalancer.ingress[].hostname}");echo
# > a66d518269ca3460ca2205ee8382f7d8-1912011121.us-east-1.elb.amazonaws.com
$ printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
# > UJFuKBDyeqBpyv0rYCimP9

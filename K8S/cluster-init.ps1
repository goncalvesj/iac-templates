kubectl create namespace ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx `
    --namespace ingress `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --version v1.3.0 `
  --set installCRDs=true

# kubectl apply `
#     --namespace m3u-split `
#     -f cluster-issuer.yaml

# kubectl apply `
#     --namespace m3u-split `
#     -f ingress.yaml

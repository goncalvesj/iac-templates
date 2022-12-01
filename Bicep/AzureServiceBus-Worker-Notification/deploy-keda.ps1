$LZ1RG = "CHANGE_ME"

# --- K8s Operations ---

# Create K8s Namespace
$K8sNamespace = "keda-dotnet-sample"
kubectl create namespace $K8sNamespace

# Create KEDA Secret
$QueueName = "input-queue"
$SBUS=$(az servicebus namespace list -g $LZ1RG --query "[0].name" -o tsv)

$KEDACONNSTRING=$(az servicebus queue authorization-rule keys list -g $LZ1RG --namespace-name $SBUS --queue-name $QueueName -n keda-monitor --query primaryConnectionString -o tsv)
kubectl create secret -n $K8sNamespace generic keda-monitor-secret --from-literal servicebus-connectionstring="$KEDACONNSTRING"

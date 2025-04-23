# Show logs for a kube pod matching the first argument
kubelogs(){
    local POD_PATTERN=$1
    local EXTRA_ARGS=${@:2}
    if [[ $POD_PATTERN == "" ]]
    then
        echo "Please specify a pod name search pattern."
        return
    fi
    echo "Getting Pods..."
    echo "==============="
    local PODS=$( kubectl get pods | tee /dev/tty | grep $POD_PATTERN )
    echo ""
    if [[ $PODS == "" ]]
    then
        echo "No matching pods found for '$POD_PATTERN'."
        return
    fi
    local MATCH_COUNT=$(wc -l <<< "$PODS")
    if [[ $MATCH_COUNT -gt 1 ]]
    then
        echo "Too many matching pods found: $MATCH_COUNT"
        echo "$PODS"
        return
    fi
    local POD_NAME=$(cut -d " " -f1 <<< "$PODS")
    local HEADER="Logs for $POD_NAME as of $(date):"
    echo $HEADER
    printf '=%.0s' $(seq 1 $(wc -c <<< "$HEADER"))
    echo ""
    kubectl logs $POD_NAME $EXTRA_ARGS

    echo ""
    echo "============================================================"
    echo "Note: Use the \"-c\" flag to show a different container's logs"
    echo ""
    local CONTAINER_LIST=$(kubectl get pods ${POD_NAME} -o jsonpath='{.spec.containers[*].name}')
    echo "Available containers for $POD_NAME:"
    printf " - %s\n" $CONTAINER_LIST
}

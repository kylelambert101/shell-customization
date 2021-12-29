#!/usr/bin/env bash

# Show logs for a kube pod matching the first argument
kubelogs(){
    local POD_PATTERN=$1
    if [[ $POD_PATTERN == "" ]]
    then
        echo "Please specify a pod name search pattern."
        exit
    fi
    echo "Getting Pods..."
    echo "==============="
    local PODS=$( kubectl get pods | tee /dev/tty | grep $POD_PATTERN )
    echo ""
    if [[ $PODS == "" ]]
    then
        echo "No matching pods found for '$POD_PATTERN'."
        exit
    fi
    local MATCH_COUNT=$(wc -l <<< "$PODS")
    if [[ $MATCH_COUNT -gt 1 ]]
    then
        echo "Too many matching pods found: $MATCH_COUNT"
        exit
    fi
    local POD_NAME=$(cut -d " " -f1 <<< "$PODS")
    local HEADER="Logs for $POD_NAME as of $(date):"
    echo $HEADER
    printf '=%.0s' $(seq 1 $(wc -c <<< "$HEADER"))
    echo ""
    kubectl logs $POD_NAME
}
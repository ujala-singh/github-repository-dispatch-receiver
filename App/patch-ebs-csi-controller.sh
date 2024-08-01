#!/bin/bash
# Define the function to get the current timestamp
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}
# Define the function to patch the ebs-csi-controller deployment
patch_ebs_csi_controller() {
    # Check if the deployment exists
    if kubectl get deployment ebs-csi-controller -n kube-system &> /dev/null; then
        # Check if the container already has the specified args and ports
        if ! kubectl get deployment ebs-csi-controller -n kube-system -o jsonpath='{.spec.template.spec.containers[?(@.name=="ebs-plugin")].args[*]}' | grep -- "--http-endpoint=0.0.0.0:3301" > /dev/null || \
           ! kubectl get deployment ebs-csi-controller -n kube-system -o jsonpath='{.spec.template.spec.containers[?(@.name=="ebs-plugin")].ports[*].containerPort}' | grep "3301" > /dev/null; then
            # Patch the ebs-csi-controller deployment
            kubectl patch deployment ebs-csi-controller -n kube-system --type='json' \
            -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--http-endpoint=0.0.0.0:3301"}, {"op": "add", "path": "/spec/template/spec/containers/0/ports/-", "value": {"containerPort": 3301, "name": "metrics", "protocol": "TCP"}}]'
            echo "[$(get_timestamp)] [INFO] Patch command executed successfully."
        else
            echo "[$(get_timestamp)] [INFO] Deployment already patched. Skipping patch operation."
        fi
    else
        echo "[$(get_timestamp)] [WARNING] Deployment ebs-csi-controller not found. Skipping patch operation."
    fi
}

# Define the function to run the patch command every 5 minutes
run_periodically() {
    while true; do
        echo "[$(get_timestamp)] [DEBUG] Running patch command..."
        patch_ebs_csi_controller
        echo "[$(get_timestamp)] [DEBUG] Sleeping for 5 minutes..."
        sleep 300  # Sleep for 5 minutes (300 seconds)
    done
}
# Execute the function to run the patch command periodically
run_periodically

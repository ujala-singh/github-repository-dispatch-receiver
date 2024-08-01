FROM ubuntu:20.04

# Install bash and wget
RUN apt-get update && apt-get install -y bash wget

# Install kubectl
RUN wget -qO /usr/local/bin/kubectl "https://dl.k8s.io/release/$(wget -qO- https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

RUN chmod +x /usr/local/bin/kubectl

# Copy the script into the container
COPY ./App/patch-ebs-csi-controller.sh /patch-ebs-csi-controller.sh

# Set executable permissions on the script
RUN chmod +x /patch-ebs-csi-controller.sh

# Set the script as the entry point
ENTRYPOINT ["/patch-ebs-csi-controller.sh"]

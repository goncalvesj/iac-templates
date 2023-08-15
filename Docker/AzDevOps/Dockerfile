FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && useradd -m agentuser

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
# These variables are passed in at runtime from env vars defined outside the Dockerfile.
ENV AZP_URL="CHANGEME"
ENV AZP_TOKEN="CHANGEME"
ENV AZP_AGENT_NAME="CHANGEME"

WORKDIR /azp
RUN chown -R agentuser:agentuser /azp
RUN chmod 755 /azp

# COPY ./start.sh .
COPY ./AzDevOps/start.sh .
RUN chmod +x start.sh

USER agentuser

ENTRYPOINT [ "./start.sh" ]
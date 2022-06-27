# syntax=docker/dockerfile:1.3-labs
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive
ENV TF_VERSION 1.1.7
ENV PACKER_VERSION 1.8.0
ENV TFSEC_VERSION 1.26.0
ENV TERRASCAN_VERSION 1.15.2

ENV VERSION 1.18.1
ENV OS linux
ENV ARCH amd64
ENV GOROOT=/usr/local/go-$VERSION
ENV GOPATH=$HOME/projects/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$PATH:$GOROOT/bin
ENV PATH=$PATH:$HOME/projects/go/bin

ENV pip_packages "ansible cryptography pywinrm kerberos requests_kerberos passlib msrest PyVmomi pymssql"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        gcc \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        krb5-user \
        krb5-config \
        libffi-dev \
        libkrb5-dev \
        libssl-dev \
        lsb-release \
        openssh-client \
        python3-dev \
        python3-gssapi \
        python3-pip \
        python3-netaddr \
        python3-jmespath \
        python3-setuptools \
        python3-wheel \
        python3-pymssql \
        sshpass \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
 
# hadolint ignore=DL3013,DL3042
RUN pip install --upgrade pip \
    && pip install $pip_packages \
    && pip install ansible[azure] \
    && ansible-galaxy collection install azure.azcollection community.general \
    && pip install --requirements ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt

RUN curl --location https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip --output terraform.zip \
    && unzip terraform.zip -d /usr/bin \
    && rm -f terraform.zip \
    && chmod +x /usr/bin/terraform

RUN curl --location https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip --output packer.zip \
    && unzip packer.zip -d /usr/bin \
    && rm -f packer.zip \
    && chmod +x /usr/bin/packer

# JSonnet
RUN curl --location https://storage.googleapis.com/golang/go${VERSION}.${OS}-${ARCH}.tar.gz --output go.tar.gz \
    && tar -xvf go.tar.gz \
    && rm -f go.tar.gz \
    && mv go go-${VERSION} \
    && mv go-${VERSION} /usr/local \
    && go install github.com/google/go-jsonnet/cmd/jsonnet@latest

RUN curl --location https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_linux_amd64.tar.gz --output tfsec.tar.gz \
    && tar -xvf tfsec.tar.gz \
    && rm -f tfsec.tar.gz \
    && install tfsec /usr/local/bin

RUN curl --location https://github.com/accurics/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz --output terrascan.tar.gz \
    && tar -xvf terrascan.tar.gz \
    && rm -f terrascan.tar.gz \
    && install terrascan /usr/local/bin

RUN curl --location "https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz" --output terraform-docs.tar.gz \
    && tar -xvf terraform-docs.tar.gz \
    && rm -f terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && install terraform-docs /usr/local/bin

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN curl --location https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64 --output hadolint \
    && chmod +x hadolint \
    && install hadolint /usr/local/bin

CMD    ["/bin/bash"]
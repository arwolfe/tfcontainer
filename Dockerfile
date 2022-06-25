FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
ENV TF_VERSION 1.1.7
ENV PACKER_VERSION 1.8.0
ENV TFSEC_VERSION 1.26.0
ENV TERRASCAN_VERSION 1.15.2
 
ENV pip_packages "ansible cryptography pywinrm kerberos requests_kerberos passlib msrest PyVmomi pymssql"
 
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
 
RUN pip install --upgrade pip \
    && pip install $pip_packages \
    && pip install ansible[azure] \
    && ansible-galaxy collection install azure.azcollection community.general \
    && pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
 
RUN curl -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/bin \
    && rm -f terraform_${TF_VERSION}_linux_amd64.zip \
    && chmod +x /usr/bin/terraform \
    && curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin \
    && rm -f packer_${PACKER_VERSION}_linux_amd64.zip \
    && chmod +x /usr/bin/packer

# JSonnet
RUN <<EOF
VERSION=1.18.1
OS=linux
ARCH=amd64
cd $HOME
wget https://storage.googleapis.com/golang/go$VERSION.$OS-$ARCH.tar.gz
tar -xvf go$VERSION.$OS-$ARCH.tar.gz
mv go go-$VERSION
sudo mv go-$VERSION /usr/local
export GOROOT=/usr/local/go-$VERSION
export GOPATH=$HOME/projects/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$HOME/projects/go/bin
cat << EOF2 >> .bashrc
export GOROOT=/usr/local/go-$VERSION
export GOPATH=\$HOME/projects/go
export GOBIN=\$GOPATH/bin
export PATH=\$PATH:\$GOROOT/bin
export PATH=\$PATH:\$HOME/projects/go/bin
EOF2
go install github.com/google/go-jsonnet/cmd/jsonnet@latest
EOF

# Scanning and tools
RUN <<EOF
pip install --upgrade pip
pip install $pip_packages
pip install ansible[azure]
ansible-galaxy collection install azure.azcollection community.general
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt

curl -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/bin
rm -f terraform_${TF_VERSION}_linux_amd64.zip
chmod +x /usr/bin/terraform

curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin
rm -f packer_${PACKER_VERSION}_linux_amd64.zip
chmod +x /usr/bin/packer

curl --location https://github.com/aquasecurity/tfsec/releases/download/v$(TFSEC_VERSION)/tfsec_$(TFSEC_VERSION)_linux_amd64.tar.gz --output tfsec.tar.gz
tar -xvf tfsec.tar.gz
sudo install tfsec /usr/local/bin

curl --location https://github.com/accurics/terrascan/releases/download/v$(TERRASCAN_VERSION)/terrascan_$(TERRASCAN_VERSION)_Linux_x86_64.tar.gz --output terrascan.tar.gz
tar -xvf terrascan.tar.gz
sudo install terrascan /usr/local/bin

curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo install terraform-docs /usr/local/bin
EOF
 
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
 
CMD    ["/bin/bash"]
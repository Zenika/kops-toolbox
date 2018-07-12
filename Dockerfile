FROM centos:7

RUN yum -y install epel-release \
    && yum -y install python-pip groff which openssh-clients bash-completion jq \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN pip install --upgrade pip

RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

ARG USER_ID
ARG GROUP_ID
RUN groupadd -g ${GROUP_ID} guest
RUN useradd -u ${USER_ID} -g ${GROUP_ID} guest
USER ${USER_ID}
WORKDIR /home/guest
ENV PATH ${PATH}:/home/guest/.local/bin:~guest/bin
RUN pip install awscli --upgrade --user
ADD --chown=guest:guest bin bin

ADD --chown=guest:guest .bashrc_custom .bashrc_custom
RUN cat ~guest/.bashrc_custom >> ~guest/.bashrc \
    && rm ~guest/.bashrc_custom

ARG KOPS_USER=my-kops-user
ENV KOPS_USER $KOPS_USER
ARG AWS_REGION=eu-west-3
ENV AWS_REGION $AWS_REGION
ARG CLUSTER_NAME=my.kops.cluster.k8s.local
ENV CLUSTER_NAME $CLUSTER_NAME
ARG DOCKER_REPO=kopstoolbox
ENV DOCKER_REPO $DOCKER_REPO

VOLUME ~guest/.aws
VOLUME ~guest/.kube
VOLUME ~guest/.ssh

CMD ["/bin/bash"]

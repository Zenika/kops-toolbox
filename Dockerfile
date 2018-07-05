FROM centos:7

RUN useradd -u 1000 guest

RUN yum -y install epel-release \
    && yum -y install python-pip groff which openssh-clients \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && echo 'complete -C '~guest/.local/bin/aws_completer' aws' >> ~guest/.bashrc

RUN pip install --upgrade pip

RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

USER 1000
WORKDIR /home/guest
ENV PATH ${PATH}:/home/guest/.local/bin:~guest/bin
RUN pip install awscli --upgrade --user
ADD --chown=guest:guest bin bin

ARG KOPS_USER=my-kops-user
ENV KOPS_USER $KOPS_USER
ARG AWS_REGION=eu-west-3
ENV AWS_REGION $AWS_REGION
ARG CLUSTER_NAME=my.kops.cluster.k8s.local
ENV CLUSTER_NAME $CLUSTER_NAME

VOLUME ~guest/.aws

CMD ["/bin/bash"]
#CMD ["/bin/bash", "-c", "source /home/guest/bin/create-aws-kops-user.sh"]

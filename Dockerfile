FROM centos:7

RUN useradd -u 1000 guest

RUN yum -y install epel-release \
    && yum -y install python-pip groff which \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && echo 'complete -C '~guest/.local/bin/aws_completer' aws' >> ~guest/.bashrc

RUN pip install --upgrade pip

RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops

USER 1000
WORKDIR /home/guest
ENV PATH ${PATH}:/home/guest/.local/bin:~guest/bin
RUN pip install awscli --upgrade --user
ADD --chown=guest:guest bin bin

ARG KOPS_USER=clevandowski-kops
ENV KOPS_USER $KOPS_USER
ARG AWS_REGION=eu-west-3
ENV AWS_REGION $AWS_REGION

VOLUME ~guest/.aws

CMD "/bin/bash"

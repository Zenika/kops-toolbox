FROM centos:7

RUN yum -y install epel-release \
    && yum -y install python-pip groff which openssh-clients bash-completion jq iproute net-tools git \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN pip install --upgrade pip

RUN curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 \
    && chmod +x kops-linux-amd64 \
    && mv kops-linux-amd64 /usr/local/bin/kops \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.478/jx-linux-amd64.tar.gz | tar xzv && mv jx /usr/local/bin \
    && curl -L https://dl.google.com/go/go1.11.linux-amd64.tar.gz | tar xzv -C /usr/local \
    && yum -y install sysstat


ARG USER_ID
ARG GROUP_ID
ARG USER_NAME
ARG GROUP_NAME

# Add group if not present
RUN if getent group ${GROUP_ID} >/dev/null; then echo "Group ${GROUP_ID} already exists"; else echo "Creating group ${GROUP_ID}"; groupadd -g ${GROUP_ID} ${GROUP_NAME}; fi
# Add user if not present
RUN if getent passwd ${USER_ID} >/dev/null; then echo "User ${USER_ID} already exists"; else echo "Creating user ${USER_ID}"; useradd -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}; fi

RUN chgrp -hR ${GROUP_ID} /usr \
    && chmod -R 770 /usr \
    && chgrp -hR ${GROUP_ID} /tmp \
    && chmod -R 770 /tmp

RUN usermod -g ${GROUP_ID} ${USER_NAME}


WORKDIR /home/${USER_NAME}
USER ${USER_ID}
ENV PATH ${PATH}:/home/${USER_NAME}/.local/bin:~${USER_NAME}/bin:~/.jx/bin:/usr/local/go/bin
RUN pip install awscli --upgrade --user

ADD .bashrc_custom .bashrc_custom
# RUN chown -R ${USER_ID}:${GROUP_ID} .bashrc_custom
RUN cat .bashrc_custom >> .bashrc \
    && rm .bashrc_custom


# Setting environment variables
ARG KOPS_USER=my-kops-user
ENV KOPS_USER $KOPS_USER
ARG KOPS_GROUP=my-kops-group
ENV KOPS_GROUP $KOPS_GROUP
ARG AWS_REGION=eu-west-3
ENV AWS_REGION $AWS_REGION
ARG CLUSTER_NAME=my.kops.cluster.k8s.local
ENV CLUSTER_NAME $CLUSTER_NAME
ARG CLUSTER_DOMAIN=my.kops.cluster.k8s.local
ENV CLUSTER_DOMAIN $CLUSTER_DOMAIN
ARG GIT_API_TOKEN=""
ENV GIT_API_TOKEN $GIT_API_TOKEN
ARG GIT_USER_NAME=""
ENV GIT_USER_NAME $GIT_USER_NAME
ARG GIT_USER_EMAIL=""
ENV GIT_USER_EMAIL $GIT_USER_EMAIL


VOLUME ~${USER_NAME}/.aws
VOLUME ~${USER_NAME}/.kube
VOLUME ~${USER_NAME}/.ssh
VOLUME ~${USER_NAME}/bin
VOLUME ~${USER_NAME}/.jx


CMD ["/bin/bash"]

kops create cluster \
--node-count=9 \
--node-size=t2.xlarge \
--master-count=3
--master-size=t2.xlarge \
--zones=${AWS_REGION}a,${AWS_REGION}b,${AWS_REGION}c \
--master-zones=${AWS_REGION}a,${AWS_REGION}b,${AWS_REGION}c \
--name=${CLUSTER_NAME}


kops update cluster --name ${CLUSTER_NAME} --yes

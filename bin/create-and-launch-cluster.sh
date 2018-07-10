kops create cluster \
--node-count=2 \
--node-size=t2.xlarge \
--master-size=t2.xlarge \
--zones=${AWS_REGION}a \
--name=${CLUSTER_NAME}


kops update cluster --name ${CLUSTER_NAME} --yes

export KOPS_USER=vincent-gilles-kops
export KOPS_GROUP=$KOPS_USER
export AWS_REGION=eu-west-3
export GCP_REGION=europe-west2
export CLUSTER_NAME=vincent.gilles.kops.k8s.local 
export DOCKER_REPO=rudemonkey 
export CLUSTER_DOMAIN=""


#soucre screts from another file with th following format
#export GIT_USER_NAME=""
#export GIT_USER_EMAIL=""
#export GIT_API_TOKEN=""

source ./secrets.sh || source ./git.sh

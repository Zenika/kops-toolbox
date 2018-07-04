#!/bin/bash

aws --profile $KOPS_USER s3api delete-bucket --bucket $KOPS_USER-state-store

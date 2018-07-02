#!/bin/bash

aws iam remove-user-from-group --user-name clevandowski-kops --group-name clevandowski-kops
aws iam delete-user --user-name clevandowski-kops

aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name clevandowski-kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name clevandowski-kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name clevandowski-kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name clevandowski-kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name clevandowski-kops

aws iam delete-group --group-name clevandowski-kops

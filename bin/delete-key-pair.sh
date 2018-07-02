#!/bin/bash

fail() {
  echo "Aborting"
  exit 1
}

aws ec2 delete-key-pair --key-name clevandowski-test-awscli || fail
rm -f ~/.ssh/clevandowski-test-awscli.pem

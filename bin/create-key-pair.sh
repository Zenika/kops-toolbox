#!/bin/bash

fail() {
  echo "Aborting"
  exit 1
}

if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
  chmod 700 .ssh
fi

aws ec2 create-key-pair --key-name clevandowski-test-awscli > ~/.ssh/clevandowski-test-awscli.pem || fail
chmod 400 .ssh/clevandowski-test-awscli.pem


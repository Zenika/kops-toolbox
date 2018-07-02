#!/bin/bash

while read \
  token_type \
  access_key_id \
  access_key_creation_date \
  secret_key_id \
  state \
  user_name; do 
  # echo "$token_type $access_key_id $access_key_creation_date $secret_key_id $state $user_name"
  printf "$access_key_id\n$secret_key_id\neu-west-3\ntext\n"
done

#!/bin/bash


git config --global --add user.name "$GIT_USER_NAME"
git config --global --add user.email "$GIT_USER_EMAIL"

jx install --batch-mode \
--provider aws \
--headless \
--git-provider-url https://github.com \
--git-username $GIT_USER_NAME \
--git-api-token $GIT_API_TOKEN \
--install-dependencies \
--no-default-environments \
--git-private

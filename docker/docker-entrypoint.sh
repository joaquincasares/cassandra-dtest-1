#!/bin/bash

set -ex

# replace placeholders with envars
sed -ri "s|AWS_ACCESS_KEY_ID|${AWS_ACCESS_KEY_ID}|" ${WORKDIR}/.aws/credentials
sed -ri "s|AWS_SECRET_ACCESS_KEY|${AWS_SECRET_ACCESS_KEY}|" ${WORKDIR}/.aws/credentials
sed -ri "s|AWS_REGION|${AWS_REGION}|" ${WORKDIR}/.aws/config

# copy again when docker-compose uses volumes,
# because volumes of `.:/usr/src/app` will overwrite all other files
cp /root/.bashrc .

# prevent broken ssh pipes
mkdir -p ${WORKDIR}/.ssh
touch ${WORKDIR}/.ssh/config
echo -n "Host *
ServerAliveInterval 3
ServerAliveCountMax 200" >> ${WORKDIR}/.ssh/config
chown -R ${USER}:${USER} ${WORKDIR}/.ssh

exec gosu ${USER} "$@"

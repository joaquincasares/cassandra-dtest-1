FROM ubuntu:16.04

ENV TERM xterm-color

# use a common app path, copied from python-onbuild:latest
ENV WORKDIR /usr/src/app
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

# install gosu: https://github.com/tianon/gosu
ENV GOSU_VERSION 1.10
RUN set -ex; \
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	apt-get purge -y --auto-remove $fetchDeps

# install cli debug tools
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        bash-completion \
        colordiff \
        curl \
        tree \
        vim \
        wget \
    && rm -rf /var/lib/apt/lists/*

# enable bash-completion
RUN echo ". /etc/bash_completion" >> ~/.bashrc \
    && echo "alias ls='ls --color=auto'" >> ~/.bashrc \
    && echo "alias tree='tree -Aash'" >> ~/.bashrc

# install aws cli tools and aws-shell (developer preview)
# https://aws.amazon.com/cli/
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        groff \
        python-pip \
    && pip install --upgrade awscli aws-shell pip \
    && rm -rf /var/lib/apt/lists/*

# http://docs.aws.amazon.com/cli/latest/userguide/cli-command-completion.html
# enable aws cli tools bash completion
RUN echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc

# install jq, command line json parser
# https://stedolan.github.io/jq
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        jq

# install dnsutils, in order to install dig, to allow us to find the host
# machine's public IP address to be used in setting up AWS security groups
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        dnsutils

# install ssh to communicate with ec2 instance
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        rsync \
        ssh

# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#/user
# downgrade since we don't need root privileges
ENV USER aws
RUN groupadd --system $USER && useradd --system --home-dir ${WORKDIR} --gid $USER $USER
RUN chown $USER:$USER ${WORKDIR}

# copy aws configs into container
COPY .aws/* ${WORKDIR}/.aws/
RUN chown -R ${USER}:${USER} ${WORKDIR}/.aws \
    && chmod 600 ${WORKDIR}/.aws/*

# add the ability to daisychain envars
RUN echo "set -o allexport\nsource ${WORKDIR}/bash.env\nset +o allexport" >> ~/.bashrc

# copy bashrc and switch to non-root user
RUN cp ~/.bashrc `eval echo ~${USER}` \
    && chown ${USER}:${USER} `eval echo ~${USER}`/.bashrc

# copy block device mappings into container
COPY conf/ ${WORKDIR}/conf

COPY bash.env docker-entrypoint.sh ${WORKDIR}/
ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]
CMD bash

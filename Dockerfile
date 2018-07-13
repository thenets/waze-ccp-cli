FROM ubuntu:18.04

ENV USER_NAME=kratos
ENV USER_HOME=/home/$USER_NAME
ENV APP=/app

RUN apt-get update && apt-get install -y \
        aufs-tools automake build-essential curl dpkg-sig libcap-dev \
        libsqlite3-dev virtualenv wget \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN set -x \
    && groupadd -r -g 1000 $USER_NAME \
    && useradd -mr -c $USER_NAME -d $USER_HOME -g 1000 -u 1000 $USER_NAME

# Bash setup
RUN set -x \
    # Colorful root bash
    && echo 'export PS1="\e[1m\e[91mGodOfWar\e[39m:\e[96m\w\e[0m# "' > /root/.bashrc \
    # Colorful limited user bash
    && echo 'export PS1="\e[1m\e[32m\\u\e[39m@\e[34masgard\e[39m:\e[96m\w\e[0m$ "' > $USER_HOME/.bashrc \
    # Fix permissions
    && chown -R $USER_NAME.$USER_NAME $USER_HOME

RUN apt-get update && apt-get install -y \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN set -x \
    # HACK Alias from 'python' tp 'python3'
    && ln -s /usr/bin/python3 /usr/bin/python \
    # HACK to fix volume permissions
    && mkdir -p $USER_HOME/.pyenv/versions \
    # Create and start venv
    && echo 'if [ ! -f $USER_HOME/.pyenv/versions/venv ]; then ' >> $USER_HOME/.bashrc \
    && echo '    cd $USER_HOME/.pyenv/versions' >> $USER_HOME/.bashrc \
    && echo '    virtualenv -p python3 venv' >> $USER_HOME/.bashrc \
    && echo '    cd -' >> $USER_HOME/.bashrc \
    && echo 'fi' >> $USER_HOME/.bashrc \
    && echo 'source $USER_HOME/.pyenv/versions/venv/bin/activate' >> $USER_HOME/.bashrc

WORKDIR $APP
ADD ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

VOLUME ['/home/kratos/.pyenv/versions']
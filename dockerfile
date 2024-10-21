FROM ubuntu:20.04

ARG HOME=/home/user
ARG USER=user
ARG GROUP=usergroup
ARG ARG_UID=1000
ARG ARG_GID=1000

ARG DEBIAN_FRONTEND=noninteractive

ENV UID=${ARG_UID}
ENV GID=${ARG_GID}
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y gawk wget git-core diffstat unzip \
            texinfo gcc-multilib build-essential chrpath socat cpio python \
            python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
            python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm locales \
            libgmp-dev libmpc-dev libsdl1.2-dev libssl-dev lz4 pylint \
            vim bash-completion screen zstd iproute2 iptables sudo \
            bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm \
            nano libncurses-dev

# needed by bitbake
RUN locale-gen en_US.UTF-8

# make user sudo command password-less
RUN echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

# Create a group and user
#--disabled-password prevents prompt for a password
#--gecos "" circumvents the prompt for "Full Name" etc. on Debian-based systems
#--home "$(pwd)" sets the user's home to the WORKDIR. You may not want this.
#--no-create-home prevents cruft getting copied into the directory from /etc/skel
RUN addgroup --gid ${GID} ${GROUP}

#RUN adduser \
#    --disabled-password \
#    --gecos "" \
#    --home "${HOME}" \
#    --ingroup "${GROUP}" \
#    --uid "${UID}" \
#    "${USER}"
RUN useradd -r -l -u ${UID} -g ${GID} -m -d ${HOME} ${USER}

# Tell docker that all future commands should run as the appuser user
RUN chown -R ${UID}:${GID} ${HOME}
USER user

# Create home endpoint
RUN mkdir -p ${HOME}/work
WORKDIR ${HOME}/work

# needed by some recipes
RUN git config --global user.email "user@user.com"
RUN git config --global user.name "Container User"

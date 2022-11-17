FROM debian:stable-slim AS base

WORKDIR /root

ENV LC_ALL C
ENV TZ=UTC
ENV DEBIAN_FRONTEND noninteractive

RUN echo 'APT::Install-Recommends "0"; \n\
APT::Install-Suggests "0"; \n\
APT::Get::Assume-Yes "true"; \n\
' > /etc/apt/apt.conf.d/noninteractive
ONBUILD RUN apt-get update

## Build container

FROM base AS build

RUN apt-get install -y build-essential automake autoconf

RUN mkdir /src
WORKDIR /src
COPY . /src

RUN autoreconf -fvi && \
	./configure && \
	make && \
	make check && \
	make install

## Terminal Server Access Point (TSAP) for SSH

FROM base AS tsap-ssh

RUN apt-get install -y openssh-server
RUN rm -vf /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub

COPY --from=build /usr/local/bin/ts-client /usr/local/bin/
RUN echo "session required pam_exec.so stdout /usr/local/bin/ts-client" >> /etc/pam.d/sshd
RUN echo "session required pam_deny.so" >> /etc/pam.d/sshd
CMD ["/usr/sbin/sshd", "-D", "-e"]

## SSH TSAP - Development version (enables Debug mode for sshd and
## pre-bakes a test user)
FROM tsap-ssh AS tsap-ssh-dev

RUN useradd -c 'Test User' -m testuser && \
	mkdir -p /home/testuser/.ssh && chmod 0700 /home/testuser/.ssh
ADD dev/data/ssh_client_rsa_key.pub /home/testuser/.ssh/authorized_keys
RUN chmod 600 /home/testuser/.ssh/authorized_keys && \
	chown -R testuser:testuser /home/testuser

CMD ["/usr/sbin/sshd", "-D", "-e", "-d"]


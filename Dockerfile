FROM       ubuntu:16.04
MAINTAINER Jonathan Nagayoshi "https://github.com/sonikro"

ENV OC_VERSION "v3.11.0"
ENV OC_RELEASE "openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit"

## Init
RUN apt-get update

## Install OC Library
RUN apt-get install -y wget
RUN mkdir -p /opt/oc
RUN wget -O /opt/oc/release.tar.gz https://github.com/openshift/origin/releases/download/$OC_VERSION/$OC_RELEASE.tar.gz 
RUN apt-get install ca-certificates
RUN tar --strip-components=1 -xzvf  /opt/oc/release.tar.gz -C /opt/oc/ && \
    mv /opt/oc/oc /usr/bin/ && \
    rm -rf /opt/oc

## Install OpenSSH Server
RUN apt-get install -y ca-certificates openssh-server
RUN mkdir /var/run/sshd

## Set default root password
RUN echo 'root:root' |chpasswd
RUN mkdir /root/.ssh


## Setup non-root user
RUN useradd -l -u 1000170000 -g 0 -s /bin/bash sshworker
RUN echo 'sshworker:password' | chpasswd


## Setup SSHD for SSHWorker User
WORKDIR /home/sshworker
COPY sshd_config sshd_config
COPY uid_entrypoint.sh uid_entrypoint.sh
RUN chmod +x uid_entrypoint.sh
RUN touch logs.txt

## Setup root grou permisson for openshift anyid user
RUN chown root /var/run/sshd
RUN chmod 744 /var/run/sshd
RUN chgrp -R 0 /etc && \
    chmod -R g=u /etc

RUN chgrp -R 0 /var/run/sshd && \
    chmod -R g=u /var/run/sshd

RUN chgrp -R 0 /root/.ssh && \
    chmod -R g=u /root/.ssh
    
RUN chmod g+w /var/run

RUN chmod g=u /etc/passwd

RUN chown -R sshworker:root /home/sshworker

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
ENV VISIBLE now
## Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



USER 1000170000
EXPOSE 2222


ENTRYPOINT [ "/home/sshworker/uid_entrypoint.sh" ]

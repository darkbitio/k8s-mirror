FROM ruby:2.7.2-alpine3.13

ARG K8S_VERSION=1.18.8
ENV K8S_VERSION=${K8S_VERSION}

# Install tools and etcd and get the api-server binary
RUN apk add --no-cache --update -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    bash tar git curl jq etcd etcd-ctl etcd-openrc openrc less && \
    gem install pry && \
    curl -Lo kube-apiserver https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/amd64/kube-apiserver && \
    chmod +x ./kube-apiserver && \
    mv ./kube-apiserver /usr/local/bin && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

# Copy in startup script, k8s token file for auth, and the auger binary
ADD support/launch.sh /
ADD support/tokens.txt /
ADD support/load.rb /

# Make exec
RUN chmod +x /launch.sh /load.rb
# Necessary for the auger binary to run
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

EXPOSE 31337
CMD ["/bin/bash", "-c", "/launch.sh"]

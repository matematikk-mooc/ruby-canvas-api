FROM ubuntu:16.04
RUN apt-get -y update
RUN apt-get -y install vim
RUN apt-get -y install ruby
RUN apt-get -y install build-essential patch
RUN apt-get -y install ruby-dev zlib1g-dev liblzma-dev
RUN apt-get -y install curl libcurl4-openssl-dev
RUN apt-get -y intall git
WORKDIR /
RUN git clone https://github.com/matematikk-mooc/canvas-api.git
RUN gem install canvas-api
ENV CURL_CA_BUNDLE=/canvas-api/mmooc.crt
WORKDIR /canvas-api
CMD ["/bin/bash","/canvas-api"]
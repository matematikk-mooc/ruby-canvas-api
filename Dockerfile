FROM ubuntu:16.04
RUN apt-get -y update
RUN apt-get -y install vim
RUN apt-get -y install ruby
RUN apt-get -y install build-essential patch
RUN apt-get -y install ruby-dev zlib1g-dev liblzma-dev
RUN apt-get -y install libcurl4-openssl-dev
RUN gem install canvas-api
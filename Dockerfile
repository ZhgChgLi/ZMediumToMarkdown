FROM ruby:2.6.5

RUN mkdir -p /home/ZMediumFetcher/
WORKDIR /home/ZMediumFetcher
RUN gem install bundler:2.3.13
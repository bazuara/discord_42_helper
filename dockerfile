FROM ruby:3.0.0
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install vim -y
# Create folder structure for app
RUN mkdir /usr/app
WORKDIR /usr/app
# Install dependencies
COPY Gemfile /usr/app
RUN bundle install

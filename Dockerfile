FROM ruby:3.0
COPY main.rb Gemfile /
RUN bundle install 
CMD ruby main.rb

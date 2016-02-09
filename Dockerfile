FROM ruby:2.2

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

COPY . /usr/src/app

RUN bundle install --without development,test --jobs 4 --retry 3
RUN bundle exec rake tmp:clear assets:clean assets:precompile --trace

EXPOSE 3000

CMD ["puma", "-p", "3000"]

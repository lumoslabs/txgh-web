FROM ruby:2.5

RUN apt-get update && apt-get install -y redis-server mysql-client sqlite3 nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install --without development test --jobs 4 --retry 3
COPY . /usr/src/app
RUN bundle exec rake tmp:clear assets:clean assets:precompile --trace

EXPOSE 3000

CMD ["foreman", "start"]

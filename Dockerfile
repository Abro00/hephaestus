FROM ruby:3.1.2-alpine

RUN apk add --update tzdata && \
    cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    echo "Europe/Moscow" > /etc/timezone

RUN apk add --update --virtual runtime-deps postgresql-client nodejs libffi-dev readline yarn

WORKDIR /tmp
ADD Gemfile* ./

RUN apk add --virtual build-deps build-base openssl-dev postgresql-dev libc-dev linux-headers libxml2-dev libxslt-dev readline-dev && \
    bundle install --jobs=2 && \
    apk del build-deps

COPY . /app
WORKDIR /app
RUN bundle exec rails assets:precompile

ENV RAILS_ENV=production \
    RACK_ENV=production

EXPOSE 3000

CMD bundle exec rails db:create db:migrate && bundle exec rails s -b 0.0.0.0 & bundle exec rails telegram:bot:poller

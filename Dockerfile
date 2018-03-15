FROM ruby:2.2.2

WORKDIR /app

ENV RAILS_ENV production

ADD . /app/

RUN echo 'gem: --no-document --no-rdoc --no-ri' > /etc/gemrc \
    && gem install bundler --no-document --no-rdoc --no-ri

RUN  bundle install --path=/app/.bundle

RUN apt-get update &&\
    apt-get install nodejs -y

EXPOSE 8080

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0","-p", "8080"]

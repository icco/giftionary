FROM ruby:2.4.2

WORKDIR /opt

ENV LANG C.UTF-8

COPY . .

RUN bundle install

EXPOSE 8080

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]

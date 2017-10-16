FROM ruby:2.4.2

WORKDIR /opt

ENV PORT 8080
ENV LANG C.UTF-8

COPY . .

RUN bundle install

EXPOSE 8080
CMD ["rackup"]

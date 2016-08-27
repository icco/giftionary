FROM ruby:2.3.0-onbuild
ENV PORT 9393
EXPOSE $PORT
CMD ["rackup"]

FROM ruby:2.7-alpine

RUN mkdir /puppetlabs-lint /puppet

VOLUME /puppet
WORKDIR /puppet
ENTRYPOINT ["/puppetlabs-lint/bin/puppetlabs-lint"]
CMD ["--help"]

COPY . /puppetlabs-lint/

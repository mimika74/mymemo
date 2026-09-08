FROM ruby:2.6.3-buster

# Debian buster is EOL; its APT repositories now live on archive.debian.org.
RUN set -eux; \
    sed -i \
      -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
      -e 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' \
      -e 's|http://deb.debian.org/debian-security|http://archive.debian.org/debian-security|g' \
      -e '/buster-updates/d' \
      /etc/apt/sources.list; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# System packages:
#  - build-essential / pkg-config / zlib1g-dev : native gem compilation (nokogiri, etc.)
#  - git                                        : bundler needs it for the git-sourced `refile` gem
#  - default-libmysqlclient-dev                 : mysql2 gem (production DB)
#  - libsqlite3-dev                             : sqlite3 gem (ungrouped in the Gemfile)
#  - imagemagick                                : refile-mini_magick image processing
#  - nodejs                                     : JS runtime for uglifier during assets:precompile
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      git \
      default-libmysqlclient-dev \
      libsqlite3-dev \
      zlib1g-dev \
      imagemagick \
      nodejs \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_ENV=production

WORKDIR /app

# Match the Bundler version recorded in Gemfile.lock (BUNDLED WITH 1.17.3).
RUN gem install bundler -v 1.17.3

COPY Gemfile Gemfile.lock ./
# refile is a vendored path gem — it must be present before `bundle install`.
COPY vendor/gems ./vendor/gems
RUN bundle install --without development test

COPY . .

# Precompile assets at BUILD time so the runtime image actually contains them.
# (config.assets.compile is false in production; a throwaway `docker run` would
# not persist the output.) No DB connection is needed for precompile.
RUN SECRET_KEY_BASE=dummy_precompile_only bundle exec rails assets:precompile

RUN mkdir -p tmp/pids tmp/sockets log

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

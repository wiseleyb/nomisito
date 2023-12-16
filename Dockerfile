FROM ruby:3.2.2-slim

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    git \
    build-essential \
    gnupg2 \
    less \
    libpq-dev \
    postgresql-client \
    curl \
    nodejs \
    npm \
    yarn \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
  
# Add Node.js to sources list
#RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Install Node.js version that will enable installation of yarn
#RUN apt-get install -y --no-install-recommends \
#    nodejs \
#  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem update --system && \
    gem install bundler && \
    gem install rails

WORKDIR /usr/src/app

COPY . .

RUN bundle install
RUN rm -f yarn.lock
RUN rm -rf node_modules 
RUN npm upgrade 
RUN npm install -g yarn
RUN yarn build:css 

CMD ["irb"] 

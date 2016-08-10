FROM phusion/passenger-ruby22:latest

# Install dependancy
RUN apt-get update && \
    apt-get install -qy build-essential libreadline6-dev mysql-client python-pip && \
    pip install awscli

COPY . /home/app/
COPY docker/service_start.sh /home/service_start.sh

RUN chown app:app -R /home/app/ && \
    git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv && \
    echo '# rbenv setup' > /etc/profile.d/rbenv.sh && \
    echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh && \
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    chmod +x /etc/profile.d/rbenv.sh && \
    mkdir /usr/local/rbenv/plugins && \
    git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH "$RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV BUNDLE_WITHOUT test:development
ENV RACK_ENV production
ENV RAILS_SKIP_ASSET_COMPILATION false
ENV RAILS_SKIP_MIGRATIONS false

RUN cd /home/app/ && rbenv install && \
    ver=`cat /home/app/.ruby-version`; rbenv global $ver && \
    gem install bundler && \
    gem install bundle && \
    bundle  --gemfile=/home/app/Gemfile && \
    chmod 744 /home/service_start.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 5000

ENTRYPOINT /home/service_start.sh
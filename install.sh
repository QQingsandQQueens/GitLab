#!/bin/bash

echo "# ===================================================================== #"
echo "#                         GITLAB UBUNTU SETUP                           #"
echo "# ===================================================================== #"
echo "# ADD REPO & INSTALL: git-core                                          #"
echo "# ===================================================================== #"
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y git-core
echo "# ===================================================================== #"
echo "# INSTALLING: required packages                                         #"
echo "# ===================================================================== #"
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate
sudo apt-get install -y postfix
echo "# ===================================================================== #"
echo "# INSTALLING: ruby                                                      #"
echo "# ===================================================================== #"
mkdir /tmp/ruby && cd /tmp/ruby
curl --progress ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz | tar xz
cd ruby-2.0.0-p353
./configure --disable-install-rdoc
make
sudo make install
sudo gem install bundler --no-ri --no-rdoc
echo "# ===================================================================== #"
echo "# ADD USER: git                                                         #"
echo "# ===================================================================== #"
sudo adduser --disabled-login --gecos 'Git' git
echo "# ===================================================================== #"
echo "# SETTING UP: gitlab-shell                                              #"
echo "# ===================================================================== #"
cd /home/git
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-shell.git -b v1.9.1
cd gitlab-shell
sudo -u git -H cp config.yml.example config.yml
sudo -u git -H nano config.yml
sudo -u git -H ./bin/install
echo "# ===================================================================== #"
echo "# SETTING UP: gitlab                                                    #"
echo "# ===================================================================== #"
cd /home/git
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 6-7-stable gitlab
cd /home/git/gitlab
sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
sudo -u git -H nano config/gitlab.yml
sudo -u git -H mkdir /home/git/gitlab-satellites
sudo chown -R git log/
sudo chmod -R u+rwX  log/
sudo chown -R git tmp/
sudo chmod -R u+rwX  tmp/
sudo -u git -H mkdir tmp/pids/
sudo chmod -R u+rwX  tmp/pids/
sudo -u git -H mkdir tmp/sockets/
sudo chmod -R u+rwX  tmp/sockets/
sudo -u git -H mkdir public/uploads
sudo chmod -R u+rwX  public/uploads
sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb
sudo -u git -H nano config/unicorn.rb
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb
sudo -u git -H git config --global user.name "Git"
sudo -u git -H git config --global user.email "git@l1jplus.com"
sudo -u git -H git config --global core.autocrlf input
sudo -u git cp config/database.yml.mysql config/database.yml
sudo -u git -H nano config/database.yml
sudo -u git -H chmod o-rwx config/database.yml
echo "# ===================================================================== #"
echo "# SETTING UP: gems                                                      #"
echo "# ===================================================================== #"
cd /home/git/gitlab
sudo -u git -H bundle install --deployment --without development test postgres aws
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
sudo update-rc.d gitlab defaults 21
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
sudo service gitlab start
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

echo "# ===================================================================== #"
echo "# SETTING UP: apache                                                    #"
echo "# ===================================================================== #"
sudo gem install passenger
sudo passenger-install-apache2-module
sudo a2enmod proxy
sudo a2enmod proxy_balancer
sudo a2enmod proxy_http
sudo a2enmod rewrite









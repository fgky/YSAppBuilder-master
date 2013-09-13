def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc 'Install everything onto the server'
  task :install do
    run "#{sudo} locale-gen en_US.UTF-8"
    run "#{sudo} apt-get -y update"

    run "#{sudo} apt-get -y install software-properties-common"
    run "#{sudo} apt-get -y install python-software-properties"

    # For rvm
    run "#{sudo} apt-get -y --no-install-recommends install bash curl git patch bzip2"
    # For ruby
    run "#{sudo} apt-get -y --no-install-recommends install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion pkg-config libffi-dev"

    # For zip
    run "#{sudo} apt-get -y --no-install-recommends install zip"
    run "#{sudo} apt-get -y --no-install-recommends install unzip"

    # Redis
    run "#{sudo} apt-get -y install redis-server"

    # graphicsmagick
    run "#{sudo} apt-get -y install graphicsmagick"
  end
end


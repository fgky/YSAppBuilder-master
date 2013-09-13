namespace :android_sdk do
  desc 'Install Android SDK'
  task :install do
    #run "#{sudo} add-apt-repository -y ppa:upubuntu-com/sdk"
    #run "#{sudo} add-apt-repository -y ppa:nilarimogard/webupd8"
    run "#{sudo} dpkg --add-architecture i386"
    run "#{sudo} apt-get -y update"
    #run "#{sudo} apt-get -y install android-sdk"
    #run "#{sudo} apt-get -y install ia32-libs"
    #run "#{sudo} apt-get -y install android-tools-adb android-tools-fastboot"
    run "#{sudo} apt-get -y install openjdk-6-jdk"
    run "#{sudo} apt-get -y install ant"
    run "#{sudo} wget http://dl.google.com/android/android-sdk_r22.0.1-linux.tgz -P /opt"
    run "cd /opt; #{sudo} tar -xvzf android-sdk_r22.0.1-linux.tgz"
    run "cd /opt; #{sudo} chown -R `whoami`:`whoami` android-sdk-linux"
    run "/opt/android-sdk-linux/tools/android update sdk --no-ui --force" do |channel, stream, data|
      if data =~ /\[y\/n\]/i
        channel.send_data("y\n")
      else
        # use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(channel, stream, data)
      end
    end
  end
  after 'deploy:install', 'android_sdk:install'
end


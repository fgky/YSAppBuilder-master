require 'open3'

class AndroidWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(build_id)
    build = Build.find(build_id)
    project = build.project

    Rails.logger.info "#{project.name}:#{build_id} ANDROID start building."

    # Refactor!!
    template_path = "#{Rails.root}/lib/templates/Android/"
    build_path = "#{Rails.root}/tmp/builds/#{SecureRandom.hex}/"

    FileUtils.mkdir_p(build_path)
    FileUtils.cp_r(template_path, build_path)

    Dir.chdir("#{build_path}/Android/YSAppBuilder") do

      # modify `res/xml/config.xml`
      config_doc = Nokogiri::XML(File.read('res/xml/config.xml'))
      config_doc.at_css('/widget/content').attribute('src').content = project.url
      File.open('res/xml/config.xml', 'w') { |f| f.write(config_doc) }

      # modify `res/values/strings.xml`
      config_doc = Nokogiri::XML(File.read('res/values/strings.xml'))
      config_doc.at_css('/resources/string').content = project.display_name
      File.open('res/values/strings.xml', 'w') { |f| f.write(config_doc) }

      # modify `AndroidManifest.xml`
      filepath = 'AndroidManifest.xml'
      config_doc = File.read(filepath)
      replace = config_doc.gsub(/YSAppBuilder/, project.name)
      File.open(filepath, "w") {|file| file.puts replace}

      # replace icons
      FileUtils.cp(project.icon_144.android.path, 'res/drawable/icon.png')
      FileUtils.cp(project.icon_144.android_ldpi.path, 'res/drawable-ldpi/icon.png')
      FileUtils.cp(project.icon_144.android_mdpi.path, 'res/drawable-mdpi/icon.png')
      FileUtils.cp(project.icon_144.android_hdpi.path, 'res/drawable-hdpi/icon.png')
      FileUtils.cp(project.icon_144.android.path, 'res/drawable-xhdpi/icon.png')

      # replace splash screens
      FileUtils.cp(project.splash_screen_image.android.path, 'res/drawable/splash.png')
      FileUtils.cp(project.splash_screen_image.android_ldpi.path, 'res/drawable-ldpi/splash.png')
      FileUtils.cp(project.splash_screen_image.android_mdpi.path, 'res/drawable-mdpi/splash.png')
      FileUtils.cp(project.splash_screen_image.android_hdpi.path, 'res/drawable-hdpi/splash.png')
      FileUtils.cp(project.splash_screen_image.android.path, 'res/drawable-xhdpi/splash.png')

      # modify JPUSH KEY
      #filepath = 'AndroidManifest.xml'
      #doc = Nokogiri::XML(File.read(filepath))
      #doc.at_xpath("//meta-data[contains(@android:name, 'JPUSH_APPKEY')]").attribute('value').content = project.jpush_app_key
      #File.open(filepath, 'w') { |f| f.write(doc) }

      # modify package Java file
      filepath = 'src/com/sumiapp/YSAppBuilder/YSAppBuilder.java'
      text = File.read(filepath)
      replace = text.gsub(/YSAppBuilder/, project.name)
      File.open(filepath, "w") {|file| file.puts replace}

      filepath = 'src/com/sumiapp/YSAppBuilder/AboutActivity.java'
      text = File.read(filepath)
      replace = text.gsub(/YSAppBuilder/, project.name)
      File.open(filepath, "w") {|file| file.puts replace}

      filepath = 'src/com/sumiapp/YSAppBuilder/SplashActivity.java'
      text = File.read(filepath)
      replace = text.gsub(/YSAppBuilder/, project.name)
      File.open(filepath, "w") {|file| file.puts replace}

      # rename Java file
      FileUtils.mv 'src/com/sumiapp/YSAppBuilder/YSAppBuilder.java', "src/com/sumiapp/YSAppBuilder/#{project.name}.java"

      # rename package folder
      FileUtils.mv 'src/com/sumiapp/YSAppBuilder', "src/com/sumiapp/#{project.name}"

      #`ANDROID_HOME=~/android-sdk-linux ~/android-sdk-linux/tools/android update project --path .`
      android_home = ENV['ANDROID_HOME'] || '/opt/android-sdk-linux'

      3.times do |n|
        Open3.popen3({"ANT_OPTS" => "-Xms256m -Xmx1024m", "ANDROID_HOME" => android_home}, "ant release") {|stdin, stdout, stderr, wait_thr|

          pid = wait_thr.pid # pid of the started process.
          begin
            Rails.logger.info "#{project.name}:#{build_id} ANDROID packing... (Try: #{n})"
            Timeout.timeout(20) do
              exit_status = wait_thr.value # Process::Status object returned.
              Rails.logger.info "#{project.name}:#{build_id} ANDROID status: #{exit_status}. (Try: #{n})"
              unless exit_status.success?
                Rails.logger.error "#{project.name}:#{build_id} ANDROID Build error: #{stderr.read}. (Try: #{n})"
              end
            end
          rescue Timeout::Error
            Process.kill 9, pid
            Rails.logger.info "#{project.name}:#{build_id} ANDROID Timeout and killed, PID: #{pid}. (Try: #{n})"
            Rails.logger.info "Timeout 20 because the compile process `$ aapt crunch ...` will sleep forever after it has finished."
          end
        }

        sleep 3
      end

      Open3.popen3({"ANT_OPTS" => "-Xms256m -Xmx1024m", "ANDROID_HOME" => android_home}, "ant release") {|stdin, stdout, stderr, wait_thr|

        Rails.logger.info "#{project.name}:#{build_id}[STEP 2] ANDROID packing..."

        pid = wait_thr.pid # pid of the started process.
        exit_status = wait_thr.value # Process::Status object returned.

        unless exit_status.success?
          Rails.logger.error "#{project.name}:#{build_id}[STEP 2] ANDROID Build error: #{stderr.read}."
        end
      }

      build.update_attributes(android_file: File.open("bin/YSAppBuilder-release.apk"))

      Rails.logger.info "#{project.name}:#{build_id} ANDROID finished building."
    end
  end
end


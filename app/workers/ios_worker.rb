require 'open3'

class IosWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(build_id)
    build = Build.find(build_id)
    project = build.project

    Rails.logger.info "#{project.name}:#{build_id} iOS start building."

    # Refactor!!
    template_path = "#{Rails.root}/lib/templates/Payload/"
    build_path = "#{Rails.root}/tmp/builds/#{SecureRandom.hex}/"

    FileUtils.mkdir_p(build_path)
    FileUtils.cp_r(template_path, build_path)

    Dir.chdir(build_path) do
      app = "Payload/#{project.name}.app"
      FileUtils.mv('Payload/YBAppBuilder.app', app)

      Dir.chdir(app) do
        # raname executable
        FileUtils.mv('YBAppBuilder', project.name)

        # replace icons
        FileUtils.cp(project.icon_144.iphone.path, 'icon.png')
        FileUtils.cp(project.icon_144.iphone_retina.path, 'icon@2x.png')
        FileUtils.cp(project.icon_144.ipad.path, 'icon-72.png')
        FileUtils.cp(project.icon_144.ipad_retina.path, 'icon-72@2x.png')

        # replace splash screen images
        FileUtils.cp(project.splash_screen_image.iphone.path, 'Default~iphone.png')
        FileUtils.cp(project.splash_screen_image.iphone_retina.path, 'Default@2x~iphone.png')

        # modify `config.xml`
        config_doc = Nokogiri::XML(File.read('config.xml'))
        config_doc.at_css('/widget/content').attribute('src').content = project.url
        File.open('config.xml', 'w') { |f| f.write(config_doc) }

        # modify `Info.plist`
        plist = CFPropertyList::List.new(:file => "Info.plist")
        data = CFPropertyList.native_types(plist.value)

        data['CFBundleName'] = project.name
        data['CFBundleDisplayName'] = project.display_name
        data['CFBundleExecutable'] = project.name
        data['CFBundleIdentifier'] = "com.sumiapp.#{project.name}"

        plist.value = CFPropertyList.guess(data)
        plist.save("Info.plist", CFPropertyList::List::FORMAT_BINARY)

        # modify `PushConfig.plist`
        #plist = CFPropertyList::List.new(file: 'PushConfig.plist')
        #data = CFPropertyList.native_types(plist.value)
        #data['APS_FOR_PRODUCTION'] = '1'
        #data['APP_KEY'] = project.jpush_app_key
        #plist.value = CFPropertyList.guess(data)
        #plist.save("PushConfig.plist", CFPropertyList::List::FORMAT_XML)
      end

      Open3.popen3("zip -r #{project.name}.ipa Payload") {|stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
        exit_status = wait_thr.value # Process::Status object returned.

        unless exit_status.success?
          Rails.logger.error "#{project.name}:#{build_id} iOS Build error: #{stderr.read}"
        end
      }

      build.update_attributes(ios_file: File.open("#{project.name}.ipa"))

      Rails.logger.info "#{project.name}:#{build_id} iOS finish building."
    end
  end
end


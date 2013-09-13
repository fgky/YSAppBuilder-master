if File.exists?("#{Rails.root}/lib/templates/YBAppBuilder-#{ENV['TEMPLATE_RELEASE']}.zip")
  Rails.logger.debug 'iOS template already downloaded.'
else
  `wget #{ENV['YS_APP_BUILDER_ADAM_IOS_URL']} -P lib/templates/`
  Dir.chdir("#{Rails.root}/lib/templates") do
    `unzip YBAppBuilder-#{ENV['TEMPLATE_RELEASE']}.zip`
  end
  Rails.logger.debug 'Template downloaded.'
end

if File.exists?("#{Rails.root}/lib/templates/YSAppBuilder-Android-#{ENV['TEMPLATE_RELEASE']}.zip")
  Rails.logger.debug 'Android template already downloaded.'
else
  `wget #{ENV['YS_APP_BUILDER_ADAM_ANDROID_URL']} -P lib/templates/`
  Dir.chdir("#{Rails.root}/lib/templates") do
    `unzip YSAppBuilder-Android-#{ENV['TEMPLATE_RELEASE']}.zip -d Android`
  end
  Rails.logger.debug 'Template downloaded.'
end


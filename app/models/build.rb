class Build < ActiveRecord::Base
  belongs_to :project

  mount_uploader :ios_file, IpaUploader
  mount_uploader :android_file, ApkUploader

  after_commit :run_builder, on: :create

  def to_plist
    {
      items: [
        assets: [
          {
            kind: 'software-package',
            url: ENV['HOST'] + Rails.application.routes.url_helpers.project_build_path(self.project, self, format: 'ipa')
          }
        ],
        metadata: {
          'bundle-identifier' => "com.sumiapp.#{self.project.name}",
          'bundle-version' => '1.0.0',
          kind: 'software',
          title: self.project.name
        }
      ]
    }.to_plist
  end

  private

  def run_builder
    IosWorker.perform_async(self.id)
    sleep 5
    AndroidWorker.perform_async(self.id)
  end
end

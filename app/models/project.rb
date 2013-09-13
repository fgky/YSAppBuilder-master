class Project < ActiveRecord::Base
  has_many :builds, dependent: :destroy

  mount_uploader :icon_144, IconUploader
  mount_uploader :splash_screen_image, SplashScreenUploader

  validates :name, :url, :icon_144, :splash_screen_image,
    presence: true

  validates :name,
    format: {
      with: /\A[A-Z]\w*\z/
    },
    allow_blank: true

  validates :name, uniqueness: true

  def rebuild
    builds.delete_all && builds.create
  end
end

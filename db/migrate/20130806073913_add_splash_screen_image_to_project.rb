class AddSplashScreenImageToProject < ActiveRecord::Migration
  def change
    add_column :projects, :splash_screen_image, :string
  end
end

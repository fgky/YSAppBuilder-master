class AddAndroidFileToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :android_file, :string
  end
end

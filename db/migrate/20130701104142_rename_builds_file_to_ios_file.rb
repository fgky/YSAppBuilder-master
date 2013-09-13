class RenameBuildsFileToIosFile < ActiveRecord::Migration
  def change
    rename_column :builds, :file, :ios_file
  end
end

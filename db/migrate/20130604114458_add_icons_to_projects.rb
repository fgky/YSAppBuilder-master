class AddIconsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :icon_57, :string
    add_column :projects, :icon_72, :string
    add_column :projects, :icon_114, :string
    add_column :projects, :icon_144, :string
  end
end

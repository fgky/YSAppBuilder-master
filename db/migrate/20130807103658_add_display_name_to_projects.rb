class AddDisplayNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :display_name, :string
  end
end

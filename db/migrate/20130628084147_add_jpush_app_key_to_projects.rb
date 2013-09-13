class AddJpushAppKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :jpush_app_key, :string
  end
end

class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.string :file
      t.references :project

      t.timestamps
    end
    add_index :builds, :project_id
  end
end

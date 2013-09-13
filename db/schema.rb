# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130807103658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: true do |t|
    t.string   "ios_file"
    t.integer  "project_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "android_file"
  end

  add_index "builds", ["project_id"], name: "index_builds_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "icon_57"
    t.string   "icon_72"
    t.string   "icon_114"
    t.string   "icon_144"
    t.string   "jpush_app_key"
    t.string   "splash_screen_image"
    t.string   "display_name"
  end

end

class BuildsController < ApplicationController

  before_filter :set_project
  before_action :set_build, only: [:show]

  # GET /builds
  # GET /builds.json
  def index
    @builds = @project.builds.order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @builds }
    end
  end

  # GET /builds/1
  # GET /builds/1.json
  def show
    respond_to do |format|
      format.html
      format.apk {
        send_file @build.android_file.path
      }
      format.ipa {
        send_file @build.ios_file.path
      }
      format.json { render json: @build }
      format.plist { send_data @build.to_plist }
    end
  end

  # GET /builds/new
  # GET /builds/new.json
  def new
    @build = Build.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @build }
    end
  end

  # POST /builds
  # POST /builds.json
  def create
    @build = @project.builds.new

    respond_to do |format|
      if @build.save
        format.html {
          redirect_to project_build_path(@project, @build),
            notice: 'Build was successfully created.'
        }
        format.json { render json: @build, status: :created, location: @build }
      else
        format.html { render action: "new" }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_build
    @build = Build.find(params[:id])
  end
end

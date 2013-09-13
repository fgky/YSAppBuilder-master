require 'net/http'

class Embed::ProjectsController < Embed::BaseController

  before_action :set_project, only: [:show, :edit, :update]

  # GET /projects/1
  # GET /projects/1.json
  def show
    @build = @project.builds.order('created_at DESC').first

    @ios_ipa_url = project_build_url(@project, @build, format: 'ipa')
    @ios_ad_hoc_url = "itms-services://?action=download-manifest&url=#{project_build_url(@project, @build, format: 'plist')}"
    @ios_qr = RQRCode::QRCode.new(@ios_ad_hoc_url, :size => 10, :level => :h )
    @android_apk_url = project_build_url(@project, @build, format: 'apk')
    @android_qr = RQRCode::QRCode.new(@android_apk_url, :size => 6, :level => :h )

    @ios_short_url = Net::HTTP.get(URI("http://www.35nic.com/shorturl/urlapi.asp?ourl=#{@ios_ipa_url}"))
    @android_short_url = Net::HTTP.get(URI("http://www.35nic.com/shorturl/urlapi.asp?ourl=#{@android_apk_url}"))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end

  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project =
      if params[:project]
        Project.where(name: params[:project][:name]).first || Project.new(project_params)
      else
        Project.new
      end

    respond_to do |format|
      format.html {
        redirect_to edit_embed_project_url(@project) if @project.persisted?
      }
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save && @project.builds.create
        format.html { redirect_to [:embed, @project], notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update

    respond_to do |format|
      if @project.update_attributes(project_params) && @project.rebuild
        format.html { redirect_to [:embed, @project], notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end
  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).
      permit(:name, :display_name, :url, :icon_144, :splash_screen_image)
  end
end

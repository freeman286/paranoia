class ThreatsController < ApplicationController
  # GET /threats
  # GET /threats.json
  def index
    if params[:lat] && params[:long]
      @threats = Threat.find_by_lat_long(params[:lat].to_f, params[:long].to_f)
    else
      @threats = Threat.all
      
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @threats }
    end
  end

  # GET /threats/1
  # GET /threats/1.json
  def show
    @threat = Threat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @threat }
    end
  end

  # GET /threats/new
  # GET /threats/new.json
  def new
    @threat = Threat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @threat }
    end
  end

  # GET /threats/1/edit
  def edit
    @threat = Threat.find(params[:id])
  end

  # POST /threats
  # POST /threats.json
  def create
    @threat = Threat.new(params[:threat])

    respond_to do |format|
      if @threat.save
        format.html { redirect_to @threat, notice: 'Threat was successfully created.' }
        format.json { render json: @threat, status: :created, location: @threat }
      else
        format.html { render action: "new" }
        format.json { render json: @threat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /threats/1
  # PUT /threats/1.json
  def update
    @threat = Threat.find(params[:id])

    respond_to do |format|
      if @threat.update_attributes(params[:threat])
        format.html { redirect_to @threat, notice: 'Threat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @threat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /threats/1
  # DELETE /threats/1.json
  def destroy
    @threat = Threat.find(params[:id])
    @threat.destroy

    respond_to do |format|
      format.html { redirect_to threats_url }
      format.json { head :no_content }
    end
  end
end

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.search(params[:search]).limit(10);
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    if(@event.lat? && @event.long?)
      @event.location = find_region(@event.lat, @event.long)
    end

    respond_to do |format|
      if @event.save

        # Send mail
        User.find_each do |user|
            if !(@event.title.scan(/#{user.location}/i).empty? && @event.description.scan(/#{user.location}/i).empty?)
                EventMailer.event_created(@event.title, user.email).deliver
            end
        end

        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :description, :lat, :long, :location, :image)
    end

    def find_region(lat,long)
      closest = ""
      minDist = 99999

      cities = File.read('public/cities.json')
      citiesMap = JSON.parse(cities)

      citiesMap.each do |city|
        dist = haversineDist(lat,long,city['latitude'],city['longitude'])
        if dist < minDist
          minDist = dist
          closest = city['city']
        end
      end

      closest
    end

    def haversineDist(lat1,long1,lat2,long2)
      lat1 = lat1*Math::PI/180
      lat2 = lat2*Math::PI/180
      long1 = long1*Math::PI/180
      long2 = long2*Math::PI/180
      (1-Math.cos(lat2-lat1))/2 + Math.cos(lat1)*Math.cos(lat2)*((1-Math.cos(long2-long1))/2)
    end
end

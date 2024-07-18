class CustomError < StandardError; end

class ArtistsController < ApplicationController
  before_action :authorize_user, except:[:export]

  # GET /artists
  def index
    current_page =params[:page].to_i.zero? ? 1 : params[:page].to_i
    per_page = 10
    offset = (current_page - 1) * per_page
    sql = "Select * from artists"
    total = ActiveRecord::Base.connection.execute(sql).count
    totalpage = (total.to_i/per_page.to_i).to_i
    sql += " limit #{per_page} offset #{offset}"
    @artists = ActiveRecord::Base.connection.execute(sql)
    render json: { data:@artists, page: current_page,per_page:per_page, totalpage: totalpage}, status: :ok
  end

  # GET /artists/1
  def show
    sql = "Select * from artists where id = #{params[:id]}"
    artist = ActiveRecord::Base.connection.execute(sql)
    render json: artist
  end

  # POST /artists
  def create
    artist = Artist.new(name: artist_params[:name],dob: artist_params[:dob],gender: artist_params[:gender],address: artist_params[:address],first_release_year: artist_params[:first_release_year],no_of_album_released: artist_params[:no_of_album_released],id: 0)
      if artist.valid?
          values = [
        "'"+artist_params[:name]+"'",
        "'"+artist_params[:dob]+"'",
        "'"+artist_params[:gender]+"'",
        "'"+artist_params[:address]+"'",
        "'"+artist_params[:first_release_year]+"'",
        artist_params[:no_of_album_released],
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
      ]
      sql = "insert into artists (name,dob,gender,address,first_release_year,no_of_album_released,created_at, updated_at) values(#{values.join(", ")})"
      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'Artist Created successfully'}, status: :ok
    else
      render json: artist.errors, status: :unprocessable_entity
    end
  end

  def import
    i = 0
    begin
    CSV.foreach(params[:file]) do |row|
      if i == 0
        i = 1
        next
      end
      artist = Artist.new(name: row[0],dob: row[1],gender: row[2],address: row[3],first_release_year: row[4],no_of_album_released: row[5],id: 0)
      if artist.valid?
          values = [
        "'"+row[0]+"'",
        "'"+row[1]+"'",
        "'"+row[2]+"'",
        "'"+row[3]+"'",
        "'"+row[4]+"'",
        row[5],
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
        ]
        sql = "insert into artists (name,dob,gender,address,first_release_year,no_of_album_released,created_at, updated_at) values(#{values.join(", ")})"
        ActiveRecord::Base.connection.execute(sql)
      else
        # raise CustomError, "validation error" 
      end
    end
    render json: { message: 'Artist imported successfully'} ,status: :ok
    rescue CustomError => e
      render json: { error: e.message} ,status: :bad_request
      # flash[:error] = e.message
    end
  end

  # PATCH/PUT /artists/1
  def update
    artist = Artist.new(name: artist_params[:name],dob: artist_params[:dob],gender: artist_params[:gender],address: artist_params[:address],first_release_year: artist_params[:first_release_year],no_of_album_released: artist_params[:no_of_album_released],id: params[:id])
    if artist.valid?
      update_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      sql = "UPDATE artists set name = '#{artist_params[:name]}',dob = '#{artist_params[:dob]}',gender = '#{artist_params[:gender]}',address = '#{artist_params[:address]}',first_release_year = '#{artist_params[:first_release_year]}',no_of_album_released = '#{artist_params[:no_of_album_released]}',updated_at = '#{update_at}' where id = #{params[:id]}"
      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'Artist Updated successfully'}, status: :ok
    else
      render json: artist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /artists/1
  def destroy
    sql = "SELECT count(m.id) AS music FROM artists a LEFT JOIN musics m ON m.artist_id = a.id WHERE a.id = '#{params[:id]}'"
    artist = ActiveRecord::Base.connection.execute(sql).first

    if artist && artist['music'].to_i > 0
      render json: { message: 'Artist cannot be deleted, has musics'}, status: :bad_request
    else
      sql = "DELETE FROM artists WHERE id = '#{params[:id]}'"
      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'Artist Deleted successfully'}, status: :ok
    end
  end
  def export
    sql = "Select * from artists"
    artists = ActiveRecord::Base.connection.execute(sql)

    headers = ["Name", "Date of birth", "Gender", "Address", "First release year","No of album"]
    csv = CSV.generate do |csv|
      csv << headers 
      artists.each do |artist|
        csv << [artist['name'], artist['dob'], artist['gender'],artist['address'], artist['first_release_year'], artist['no_of_album_released']]
      end
    end
    send_data csv, filename: 'artists.csv', type: 'text/csv', disposition: 'attachment'
  end

  private
    # Only allow a list of trusted parameters through.
    def artist_params
      params.require(:artist).permit(:name,
      :dob,
      :gender,
      :address,
      :first_release_year,
      :no_of_album_released)
    end
end

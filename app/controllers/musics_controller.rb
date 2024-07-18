class MusicsController < ApplicationController
  before_action :authorize_user, except: [:export]

  # GET /musics
  def index
    current_page =params[:page].to_i.zero? ? 1 : params[:page].to_i
    per_page = 10
    offset = (current_page - 1) * per_page
    sql = "Select * from musics where artist_id =  #{params[:artist_id]}"
    total = ActiveRecord::Base.connection.execute(sql).count
    totalpage = (total.to_i/per_page.to_i).to_i
    sql += " limit #{per_page} offset #{offset}"
    musics = ActiveRecord::Base.connection.execute(sql)
    render json: { data:musics, page: current_page,per_page:per_page, totalpage: totalpage}, status: :ok
  end

  # GET /musics/1
  def show
    sql = "Select * from musics where id  = #{params[:id]}"
    music = ActiveRecord::Base.connection.execute(sql)
    render json: music
  end

  def create
    ActiveRecord::Base.transaction do
      music = Music.new(title: music_params[:title],album_name: music_params[:album_name],genre: music_params[:genre],artist_id: params[:artist_id],id: 0)
      if music.valid?
        values = [
        "'"+music_params[:title]+"'",
        "'"+music_params[:album_name]+"'",
        "'"+music_params[:genre]+"'",
        params[:artist_id],
          "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
          "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
        ]
        sql = "INSERT INTO musics (title,album_name,genre,artist_id, created_at, updated_at) VALUES (#{values.join(", ")})"
        update_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        ActiveRecord::Base.connection.execute(sql)
        sql2 = "UPDATE artists set no_of_album_released = no_of_album_released + 1,updated_at = '#{update_at}' where id = #{params[:artist_id]}"
        ActiveRecord::Base.connection.execute(sql2)

        render json: { message: "Music created successfully" }, status: :ok
      else
        render json: music.errors, status: :unprocessable_entity
      end 
    end
  end

  def import
    i = 0
    CSV.foreach(params[:file]) do |row|
      ActiveRecord::Base.transaction do
        if i == 0
          i = 1
          next
        end
        sql = "Select id from artists where name = '#{row[3]}'"
        artist = ActiveRecord::Base.connection.execute(sql)
        if artist.count == 0
          next
        end
        artist_id = artist.first['id'];
        music = Music.new(title: row[0],album_name: row[1],genre: row[2],artist_id: artist_id,id: 0)
        if music.valid?
          values = [
          "'"+row[0]+"'",
          "'"+row[1]+"'",
          "'"+row[2]+"'",
          artist_id,
            "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
            "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
          ]
          sql = "INSERT INTO musics (title,album_name,genre,artist_id, created_at, updated_at) VALUES (#{values.join(", ")})"
          update_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

          ActiveRecord::Base.connection.execute(sql)
          sql2 = "UPDATE artists set no_of_album_released = no_of_album_released + 1,updated_at = '#{update_at}' where id = #{artist_id}"
          ActiveRecord::Base.connection.execute(sql2)
        else
        end 
      end
    end
    render json: { message: "Music created successfully" }, status: :ok
  end

  # PATCH/PUT /musics/1
  def update
    ActiveRecord::Base.transaction do
      music = Music.new(title: music_params[:title],album_name: music_params[:album_name],genre: music_params[:genre],artist_id: params[:artist_id],id: params[:id])
      if music.valid?
        update_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        sql = "UPDATE musics set title = '#{music_params[:title]}',album_name = '#{music_params[:album_name]}',genre = '#{music_params[:genre]}',artist_id = #{params[:artist_id]},updated_at = '#{update_at}' where id = #{params[:id]}"
        ActiveRecord::Base.connection.execute(sql)
        render json: { message: 'Music Updated successfully'}, status: :ok
      else
        render json: music.errors, status: :unprocessable_entity
      end 
    end
  end

  # DELETE /musics/1
  def destroy
    ActiveRecord::Base.transaction do
      sql1 = "Select id,artist_id from musics where id = '#{params[:id]}'"
      music = ActiveRecord::Base.connection.execute(sql1)
      if music.count > 0
        sql = "DELETE FROM musics WHERE id = '#{params[:id]}'"
        ActiveRecord::Base.connection.execute(sql)
        update_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        sql2 = "UPDATE artists set no_of_album_released = no_of_album_released - 1,updated_at = '#{update_at}' where id = #{music.first['artist_id']}"
        ActiveRecord::Base.connection.execute(sql2)
        render json: { message: 'Music Deleted successfully'}, status: :ok
      else
        render json: { message: "Music doesn't exist"}, status: :bad_request	
      end
    end
  end

  def export
    sql = "Select m.title,m.album_name,m.genre,a.name from musics m join artists a on a.id = m.artist_id"
    musics = ActiveRecord::Base.connection.execute(sql)

    headers = ["Artist Name", "Title", "Album Name", "Genre"]
    csv = CSV.generate do |csv|
      csv << headers 
      musics.each do |music|
        csv << [music['name'], music['title'], music['album_name'],music['genre']]
      end
    end
    send_data csv, filename: 'musics.csv', type: 'text/csv', disposition: 'attachment'
  end
  private
    # Only allow a list of trusted parameters through.
    def music_params
      params.require(:music).permit(
        :title,
        :album_name,
        :genre)
    end
end

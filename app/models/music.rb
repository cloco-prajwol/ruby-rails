class Music < ActiveRecord::Base
    before_validation :ensure_attributes_present
    validate :validate_title
    validate :validate_genre
    validate :validate_artist
    private
    def validate_artist
        sql = "Select * from artists where id = #{artist_id}"
        unique = ActiveRecord::Base.connection.execute(sql)
        if unique.count == 0
            errors.add(:artist_id, "Must be a valid artist")
        end
    end
    def validate_title
        if id > 0
            sql = "Select * from musics where title = '#{title}' and id != #{id}"
            unique = ActiveRecord::Base.connection.execute(sql)
            if unique.count > 0
                errors.add(:title, "already taken")
            end
        else
            sql = "Select * from musics where title = '#{title}'"
            unique = ActiveRecord::Base.connection.execute(sql)
            if unique.count > 0
                errors.add(:title, "already taken")
            end
        end 
    end 
    def ensure_attributes_present
        [:title,:album_name,:genre].each do |attr|
            if self[attr].nil? 
                errors.add(attr, "is required")
            end

            if self[attr].blank?
                errors.add(attr, "can't be blank")
            end
        end
    end
    def validate_genre
        genres = ["rnb", "country", "classic", "rock", "jazz"]
        unless genres.include?(genre)
            errors.add(:genre, "is not included in the list")
        end
    end
end

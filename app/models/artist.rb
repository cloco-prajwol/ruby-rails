class Artist < ActiveRecord::Base
    # validates :name, presence: true
    # validates :dob, presence: true
    # validates :gender, presence: true,inclusion: { in: %w(m f o) }
    # validates :address, presence: true
    # validates :first_release_year, presence: true
    # validates :no_of_album_released, presence: true
    # validates_uniqueness_of :name
    before_validation :ensure_attributes_present
    validate :validate_release_year
    validate :validate_gender
    validate :validate_name

    private
    def validate_name
        if id > 0
            sql = "Select * from artists where name = '#{name}' and id != #{id}"
            unique = ActiveRecord::Base.connection.execute(sql)
            if unique.count > 0
                errors.add(:name, "already taken1")
            end
        else
            sql = "Select * from artists where name = '#{name}'"
            unique = ActiveRecord::Base.connection.execute(sql)
            if unique.count > 0
                errors.add(:name, "already taken")
            end
        end 
    end 
    def ensure_attributes_present
        [:name,:dob,:gender,:address,:first_release_year,:no_of_album_released].each do |attr|
            if self[attr].nil? 
                errors.add(attr, "is required")
            end
          if self[attr].blank?
            errors.add(attr, "can't be blank")
          end
        end
    end
    def validate_release_year
        if first_release_year.present? && first_release_year.to_i >= Date.current.year
          errors.add(:first_release_year, "must be a valid year in the past or the current year")
        end
    end
    def validate_gender
        genders = ["m", "f", "o"]
        unless genders.include?(gender)
            errors.add(:gender, "is not included in the list")
        end
    end
end

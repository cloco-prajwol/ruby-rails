class User < ActiveRecord::Base
    attr_accessor :password_confirmation

    validate :validate_email_format, :ensure_email_unique 
    before_validation :ensure_attributes_present
    validate :validate_phone_no
    validate :validate_dob
    validate :validate_password, if: :requiredOnCreate?
    validate :passwords_match

    private
  
    def validate_email_format
      unless email =~ URI::MailTo::EMAIL_REGEXP
        errors.add(:email, "is not valid")
      end
    end
    def requiredOnCreate?
        if id > 0
            false
        else
            true
        end
    end
    def ensure_email_unique
        if id > 0
            sql = "Select * from users where email = '#{email}' and id != #{id}"
            uniqueEmail = ActiveRecord::Base.connection.execute(sql)
            if uniqueEmail.count > 0
                errors.add(:email, "already taken")
            end
        else
            sql = "Select * from users where email = '#{email}'"
            uniqueEmail = ActiveRecord::Base.connection.execute(sql)
            logger = Rails.logger
            logger.info "uniqueEmail"
            logger.info  uniqueEmail.count
            if uniqueEmail.count > 0
                errors.add(:email, "already taken")
            end
        end 
    end
    def ensure_attributes_present
        [:first_name, :last_name, :email, :phone,:dob,:gender,:address].each do |attr|
          if self[attr].nil? 
            errors.add(attr, "is required")
          end
          if self[attr].blank?
            errors.add(attr, "can't be blank")
          end
        end
    end
    def validate_phone_no
        if phone.present? && !phone.match(/\A\d{10}\z/)
          errors.add(:phone, "must be a valid 10-digit number")
        end
    end
    def validate_dob
        if dob.present? && dob >= Date.today
          errors.add(:dob, "can't be in the future")
        end
    end
    def validate_password
        if password_digest.blank?
          errors.add(:password_digest, "can't be blank")
        end
        if password_digest.present? && !password_digest.match(/\A.{7,}\z/)
            errors.add(:password_digest, "must be at least 7 characters long")
        end
    end
    def passwords_match
        if password_digest != password_confirmation
          errors.add(:password_confirmation, "must match password")
        end
    end
end

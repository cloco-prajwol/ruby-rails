class CustomError < StandardError; end

class UsersController < ApplicationController
  before_action :authorize_user, except:[:register,:export]

  # GET /users
  def index
    current_page =params[:page].to_i.zero? ? 1 : params[:page].to_i
    per_page = 10
    offset = (current_page - 1) * per_page
    sql = "Select * from users"
    total = ActiveRecord::Base.connection.execute(sql).count
    totalpage = (total.to_i/per_page.to_i).to_i
    sql += " limit #{per_page} offset #{offset}"
    @users = ActiveRecord::Base.connection.execute(sql)
    render json: { data:@users, page: current_page,per_page:per_page, totalpage: totalpage}, status: :ok
  end

  # GET /users/1
  def show
    sql = "Select first_name,last_name,email,phone,dob,gender,address,created_at, updated_at from users where id = '#{params[:id]}'"
    @users = ActiveRecord::Base.connection.execute(sql)

    render json: @users
  end

  # POST /users
  def create
    user = User.new(first_name: user_params[:first_name],
    last_name: user_params[:last_name],
    email: user_params[:email],
    password_digest: user_params[:password_digest],
    password_confirmation: user_params[:password_confirmation],
    phone: user_params[:phone],
    dob: user_params[:dob],
    gender: user_params[:gender],
    address: user_params[:address],id:0)
    
    if user.valid?
          values = [
        "'"+user_params[:first_name]+"'",
        "'"+user_params[:last_name]+"'",
        "'"+user_params[:email]+"'",
        "'"+BCrypt::Password.create(user_params[:password_digest])+"'", 
        "'"+user_params[:phone]+"'",
        "'"+user_params[:dob]+"'",
        "'"+user_params[:gender]+"'",
        "'"+user_params[:address]+"'",
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
      ]
      sql = "INSERT INTO users (first_name, last_name, email, password_digest, phone, dob, gender, address, created_at, updated_at) VALUES (#{values.join(", ")})"

      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'User Created successfully'}, status: :ok
    else
        render json: user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    user = User.new(first_name: user_update_params[:first_name],
    last_name: user_update_params[:last_name],
    email: user_update_params[:email],
    phone: user_update_params[:phone],
    dob: user_update_params[:dob],
    gender: user_update_params[:gender],
    address: user_update_params[:address],id:params[:id])
    logger = Rails.logger
    logger.info "valid"
    logger.info user.valid?
    if user.valid?
      sql = "UPDATE users set first_name = '#{user_update_params[:first_name]}',last_name = '#{user_update_params[:last_name]}',email = '#{user_update_params[:email]}',phone = '#{user_update_params[:phone]}',dob = '#{user_update_params[:dob]}',gender = '#{user_update_params[:gender]}',address = '#{user_update_params[:address]}' where id = '#{params[:id]}'";

      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'User updated successfully'}, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    # @user.destroy!
    sql1 = "Select id from users where id = '#{params[:id]}'"
    user = ActiveRecord::Base.connection.execute(sql1).count
    if user > 0
      sql = "DELETE FROM users WHERE id = '#{params[:id]}'"
      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'User Deleted successfully'}, status: :ok
    else
      render json: { message: "User doesn't exist"}, status: :bad_request	
    end
  end
  def register
    user = User.new(first_name: user_params[:first_name],
    last_name: user_params[:last_name],
    email: user_params[:email],
    password_digest: user_params[:password_digest],
    password_confirmation: user_params[:password_confirmation],
    phone: user_params[:phone],
    dob: user_params[:dob],
    gender: user_params[:gender],
    address: user_params[:address],id:0)
    
    if user.valid?
          values = [
        "'"+user_params[:first_name]+"'",
        "'"+user_params[:last_name]+"'",
        "'"+user_params[:email]+"'",
        "'"+BCrypt::Password.create(user_params[:password_digest])+"'", 
        "'"+user_params[:phone]+"'",
        "'"+user_params[:dob]+"'",
        "'"+user_params[:gender]+"'",
        "'"+user_params[:address]+"'",
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
        "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
      ]
      sql = "INSERT INTO users (first_name, last_name, email, password_digest, phone, dob, gender, address, created_at, updated_at) VALUES (#{values.join(", ")})"

      ActiveRecord::Base.connection.execute(sql)
      render json: { message: 'User Created successfully'}, status: :ok
    else
        render json: user.errors, status: :unprocessable_entity
    end
  end

  def import
    i = 0
    CSV.foreach(params[:file]) do |row|
      if i == 0
        i = 1
        next
      end
      user = User.new(first_name: row[0],
      last_name: row[1],
      email: row[2],
      password_digest: '1234567',
      password_confirmation: '1234567',
      phone: row[3],
      dob: row[4],
      gender: row[5],
      address: row[6],id:0)
      logger = Rails.logger
      logger.info "valid"
      logger.info user.errors
      if user.valid?
            values = [
          "'"+row[0]+"'",
          "'"+row[1]+"'",
          "'"+row[2]+"'",
          "'"+BCrypt::Password.create('1234567')+"'", 
          "'"+row[3]+"'",
          "'"+row[4]+"'",
          "'"+row[5]+"'",
          "'"+row[6]+"'",
          "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'", 
          "'"+Time.now.strftime('%Y-%m-%d %H:%M:%S')+"'"   
        ]
        sql = "INSERT INTO users (first_name, last_name, email, password_digest, phone, dob, gender, address, created_at, updated_at) VALUES (#{values.join(", ")})"
          logger = Rails.logger
          logger.info sql
        ActiveRecord::Base.connection.execute(sql)
      else
      end
    end
        render json: { message: 'User Imported successfully'}, status: :ok
  end

  def export
    sql = "Select * from users"
    users = ActiveRecord::Base.connection.execute(sql)

    headers = ["First Name","Last Name","Email","Phone","Date of birth", "Gender", "Address"]
    csv = CSV.generate do |csv|
      csv << headers 
      users.each do |user|
        csv << [user['first_name'],user['last_name'],user['email'],user['phone'], user['dob'], user['gender'],user['address']]
      end
    end
    send_data csv, filename: 'users.csv', type: 'text/csv', disposition: 'attachment'
  end
  private
    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:first_name,:last_name,:email,:password_digest,:phone,:dob,:gender,:address,:password_confirmation)
    end
    def user_update_params
      params.require(:user).permit(:first_name,:last_name,:email,:phone,:dob,:gender,:address)
    end
end

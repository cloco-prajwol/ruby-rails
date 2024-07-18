class Auth::SessionsController < ApplicationController
    def login
        user = User.find_by(email: params[:email])
        hashed_password = user.password_digest
        if user && BCrypt::Password.new(hashed_password) == params[:password]
            expiration_time = Time.now.to_i + (3600 * 3) 
    
            payload = { 
                user_id: user.id,
                exp: expiration_time 
            }
            token = JWT.encode(payload, ENV['APP_SECRET_KEY'], 'HS256')
            render json: { message: 'Logged in successfully', token: token,user:user }
        else
            render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
    end
    def logout
        token = extract_token_from_request
        if token
          begin
            payload, _ = JWT.decode(token, ENV['APP_SECRET_KEY'], true, algorithm: 'HS256')
            payload['exp'] = Time.now.to_i
            JWT.encode(payload, ENV['APP_SECRET_KEY'], 'HS256')
            render json: { message: 'Logged out successfully' }
          rescue JWT::DecodeError
            render json: { message: 'You need to sign in or sign up before continuing' }, status: :unauthorized
          end
        else
          render json: { message: 'No token found' }, status: :unprocessable_entity
        end
    end
    private
    def extract_token_from_request
        request.headers['Authorization']&.split&.last
    end
end

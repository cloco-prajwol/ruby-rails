require 'securerandom'

# Generate a random secret key
secret_key = SecureRandom.hex(32) # Adjust the size as needed (e.g., 64 characters for a 256-bit key)

# Set the secret key as an environment variable
ENV['APP_SECRET_KEY'] = secret_key
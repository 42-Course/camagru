require "openssl"

module PasswordHasher
  SECRET = ENV["JWT_SECRET"]

  def self.hash_password(password)
    OpenSSL::HMAC.hexdigest("SHA256", SECRET, password)
  end

  def self.valid_password?(raw_password, hashed)
    hash_password(raw_password) == hashed
  end
end

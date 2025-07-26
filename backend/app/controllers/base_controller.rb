require "sinatra/base"
require_relative "../helpers/request_helper"
require_relative "../helpers/session_token"
require_relative "../lib/errors"
require_relative "../models/user"

class BaseController < Sinatra::Base
  include APIDoc

  before do
    content_type :json

    next if request.request_method == "OPTIONS"
    next if request.path_info == "/" || public_path?

    require_auth!
  end

  helpers do
    def json_body
      raw = request.body.read
      RequestHelper.safe_json_parse(raw)
    rescue Errors::ValidationError => e
      halt 400, json_error(e.message)
    end

    def json_error(message)
      {error: message}.to_json
    end

    def json_response(data, status: 200)
      status(status)
      data.to_json
    end

    attr_reader :current_user

    def public_path?
      request.path_info =~ %r{^/(auth|email|gallery|stickers|signup|login)} || request.path_info == "/"
    end
  end

  private

  def require_auth!
    token = extract_token
    payload = validate_token(token)
    user = load_user(payload["user_id"])

    @current_user = user
  end

  def extract_token
    token = request.env["HTTP_AUTHORIZATION"]&.sub(/^Bearer /, "")
    halt 401, json_error("Missing or invalid Authorization header") unless token
    token
  end

  def validate_token(token)
    payload = SessionToken.decode(token)
    halt 401, json_error("Invalid or expired session token") unless payload
    payload
  end

  def load_user(user_id)
    user = User.find_by_id(user_id)
    halt 401, json_error("Invalid user") unless user
    halt 403, json_error("Email not verified") unless user["confirmed_at"]
    user
  end
end

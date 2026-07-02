module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      reject_unauthorized_connection unless token

      payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, algorithm: "HS256").first
      user = User.find_by(id: payload["sub"])
      reject_unauthorized_connection if user.nil? || JwtDenylist.jwt_revoked?(payload, user)
      user
    rescue JWT::DecodeError
      reject_unauthorized_connection
    end
  end
end

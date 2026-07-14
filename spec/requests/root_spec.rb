require "rails_helper"

# The site's front door. These exist because "/" used to redirect everyone to the sign-in page,
# while Devise bounced anyone already signed in off the sign-in page back to "/" — a redirect loop
# for exactly the people who were logged in.
RSpec.describe "Root and the sign-in door", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "GET /" do
    it "sends a signed-out visitor to the sign-in page, without a permanent redirect" do
      get root_path

      expect(response).to redirect_to("/users/sign_in")
      # A 301 on "/" would be cached by the browser for good.
      expect(response).to have_http_status(:found)
    end

    it "serves the backoffice to a signed-in admin rather than bouncing to sign-in" do
      sign_in admin
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/sign_in when already signed in" do
    it "goes to the backoffice, not to root — root would send it back here" do
      sign_in admin
      get new_user_session_path

      expect(response).to redirect_to(backoffice_profiles_path)
    end

    it "does not loop: following the redirect arrives somewhere that is not a redirect" do
      sign_in admin
      get new_user_session_path
      follow_redirect!

      expect(response).to have_http_status(:ok)
    end
  end

  describe "web sign-up" do
    it "is not routable — the backoffice is admin-only, so self-serve accounts buy nothing" do
      get "/users/sign_up"

      # Not raised: test.rb sets show_exceptions = :rescuable, so the routing error is a 404.
      expect(response).to have_http_status(:not_found)
    end

    it "does not offer a sign-up link on the sign-in page" do
      get new_user_session_path

      expect(response.body).not_to include("Sign up")
    end

    it "cannot be used to mint an admin: the app's signup does not permit the admin flag" do
      post "/api/v1/signup", params: {
        user: { username: "sneak", email: "sneak@example.com", password: "password123",
                admin: true }
      }, as: :json

      expect(response).to have_http_status(:created)
      # Devise's sign_up sanitizer permits email/password/username — never :admin.
      expect(User.find_by(email: "sneak@example.com")).not_to be_admin
    end

    it "leaves a self-registered user shut out of the backoffice" do
      post "/api/v1/signup", params: {
        user: { username: "sneak", email: "sneak@example.com", password: "password123",
                admin: true }
      }, as: :json

      sign_in User.find_by(email: "sneak@example.com")
      get backoffice_profiles_path

      expect(response).to have_http_status(:forbidden)
    end

    it "leaves the app's own API signup alone" do
      expect {
        post "/api/v1/signup", params: {
          user: { username: "newcomer", email: "newcomer@example.com", password: "password123" }
        }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:success)
    end
  end

  it "returns a signed-out visitor to the page they were challenged for" do
    get edit_backoffice_profile_path(create(:profile))
    expect(response).to redirect_to(new_user_session_path)

    sign_in admin
    get new_user_session_path

    # stored_location_for wins over the backoffice index.
    expect(response).to redirect_to(edit_backoffice_profile_path(Catalog::Profile.last))
  end
end

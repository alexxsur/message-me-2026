require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: "existing-user", password: "password123")
  end

  test "shows the login form" do
    get login_path

    assert_response :success
    assert_select "form[action='#{login_path}'][method='post']"
    assert_select "input[name='username']"
    assert_select "input[name='password'][type='password']"
  end

  test "logs in an existing user with valid credentials" do
    post login_path, params: { username: @user.username, password: "password123" }

    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]

    follow_redirect!
    assert_select "[role='status']", text: "You have signed in."
  end

  test "rejects invalid credentials" do
    post login_path, params: { username: @user.username, password: "incorrect" }

    assert_response :unprocessable_entity
    assert_equal "Invalid username or password.", flash[:alert]
    assert_nil session[:user_id]
  end

  test "rejects a missing password" do
    post login_path, params: { username: @user.username }

    assert_response :unprocessable_entity
    assert_equal "Invalid username or password.", flash[:alert]
    assert_nil session[:user_id]
  end

  test "logs out" do
    post login_path, params: { username: @user.username, password: "password123" }
    delete logout_path

    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "chatroom requires an active session" do
    get root_path
    assert_redirected_to login_path

    post login_path, params: { username: @user.username, password: "password123" }
    get root_path
    assert_response :success
  end

  test "logged in users are redirected away from login" do
    post login_path, params: { username: @user.username, password: "password123" }
    get login_path

    assert_redirected_to root_path
    assert_equal "You are already logged in.", flash[:alert]
  end
end

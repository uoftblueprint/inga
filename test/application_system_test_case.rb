require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  private

  def sign_in_as(user)
    visit login_path
    fill_in "Username", with: user.username
    fill_in "Password", with: "password"
    click_on "Login"
    assert_text "Projects"
  end
end

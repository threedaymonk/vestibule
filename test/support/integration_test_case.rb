require 'capybara/rails'
require 'capybara/dsl'

class IntegrationTestCase < ActiveSupport::TestCase
  include Capybara
  include ActionDispatch::Assertions
  include Rails.application.routes.url_helpers
  self.default_url_options[:host] = 'http://example.com/'

  self.use_transactional_fixtures = false

  setup do
    ActionMailer::Base.deliveries.clear
    Capybara.default_selector = :css
    Capybara.save_and_open_page_path = File.join(Rails.root, 'tmp')
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

  def i_am_on(expected_path)
    assert_equal expected_path, current_path
  end

  def the_page_has_title(expected_title)
    ['h1', 'title'].each do |title_selector|
      within(title_selector) do
        assert page.has_content?(expected_title), %Q{Expected "#{expected_title}" within CSS selector '#{title_selector}', but it's not there}
      end
    end
  end

  def sign_in(user = Factory(:user))
    visit "/users/sign_in"
    # hit wierd issue never had before where sub-context setups seem to be signed in from parent context
    # when writing reason_test.rb
    unless has_content?(user.email)
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
    end
  end

  class << self
    alias :scenario :should
  end
end

Shoulda::Context.class_eval do
  alias :scenario :should
end
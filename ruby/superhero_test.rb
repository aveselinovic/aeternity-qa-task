require 'minitest/autorun'
require 'watir'

class SuperHero < MiniTest::Test

BASE_URL = 'https://superhero.com/'.freeze
WALLET_IFRAME_SOURCE = 'https://wallet.superhero.com'.freeze
EXTENSION_PATH = ['extension_0_4_2_0.crx'].freeze

def setup
   # ext_path = ['extension_0_4_2_0.crx']
   @browser = Watir::Browser.new :chrome
   @browser.goto SuperHero::BASE_URL
   Watir::Wait.until { @browser.title == "Tips - Superhero.com" }
end

def get_vuex_local_storage
  @browser.driver.local_storage['vuex']
end

def wallet_iframe
  @browser.iframe(src: SuperHero::WALLET_IFRAME_SOURCE)
end

def wait_for_wallet_iframe
  wallet_iframe.wait_until(&:present?)
end

def test_001
  assert(@browser.title.include?('Superhero.com'));
  @browser.button(text: 'Login with Web Wallet').click
  wait_for_wallet_iframe
  wallet_iframe.span(class: 'checkmark').wait_until(&:present?).click
  wallet_iframe.button(text: "Generate New Wallet").wait_until(&:enabled?).click
  wallet_iframe.div(class: "dotstyle").wait_until(&:present?)
  wallet_iframe.button(text: "Skip").wait_until(&:present?).click
  wallet_iframe.button(text: "Generate Wallet").wait_until(&:enabled?).click
  wallet_iframe.h2(text: "Wellcome on board!").wait_until(&:present?) # Yeah "Wellcome", there is typo on UI guys
  wallet_iframe.span(class: 'checkmark').wait_until(&:present?).click
  wallet_iframe.button(text: "Proceed to your Wallet").wait_until(&:enabled?).click
  @browser.window(index: 1).wait_until(&:exists?)
  sleep 3
  @browser.window(title: 'Superhero Wallet').use
  sleep 3
  @browser.button(text: 'Accept').wait_until(&:present?).wait_until(&:enabled?).double_click
  @browser.window(index: 0).use
  @browser.link(href: /user-profile/).wait_until(&:present?).click
  @browser.file_field(:name => 'avatar').set("flag.jpg")
  sleep 3
  @browser.window(index: 1).wait_until(&:exists?)
  @browser.window(title: 'Superhero Wallet').use
  sleep 3
  @browser.button(text: 'Confirm').wait_until(&:present?).wait_until(&:enabled?).double_click
  sleep 3
end

def test_002

end

def test_003
  assert(@browser.title.include?('Superhero.com'))

  # elements
  search_box = @browser.text_field(placeholder: 'Search Superhero')
  play_button = @browser.button(class: /play-button/)
  cookies_button = @browser.button(class: /cookies-button/)
  article_content = @browser.div(class: /tip__article__content/)

  article_content.wait_until(&:present?)
  local_storage = get_vuex_local_storage
  assert(search_box.exists?,'Is not present searchbox')
  search_box.set('#minimal youtube')
  sleep 3
  play_button.wait_until(&:present?).double_click
  sleep 3
  assert(cookies_button.exists?, 'Cookies button is not present')
  cookies_button.click
  cookies_button.wait_while(&:present?)
  updated_local_storage = get_vuex_local_storage
  assert(local_storage != updated_local_storage)
  sleep 10
end

def test_004

end

 def teardown
   @browser.close
 end
end

require 'minitest/autorun'
require 'watir'

$extension = ARGV.dup[0].to_s.downcase
puts 'Chrome Extension enabled: ' << $extension

class SuperHero < MiniTest::Test

BASE_URL = 'https://superhero.com/'.freeze
WALLET_URL = 'https://wallet.superhero.com'.freeze
EXTENSION_PATH = ['files/extension_0_4_2_0.crx'].freeze

def setup
  $extension == 'true' ? (@browser = Watir::Browser.new :chrome, options: {extensions: EXTENSION_PATH}) : (@browser = Watir::Browser.new :chrome)
  @browser.goto SuperHero::BASE_URL
  Watir::Wait.until { @browser.title == "Tips - Superhero.com" }
end

def get_vuex_local_storage
  @browser.driver.local_storage['vuex']
end

def wallet_iframe
  @browser.iframe(src: SuperHero::WALLET_URL)
end

def wait_for_wallet_iframe
  wallet_iframe.wait_until(&:present?)
end

def test_001_signup
  @browser.goto SuperHero::BASE_URL
  Watir::Wait.until { @browser.title == "Tips - Superhero.com" }
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
  @browser.window(title: 'Superhero Wallet').use
  @browser.button(text: 'Accept').wait_until(&:present?).wait_until(&:enabled?).double_click
  @browser.window(index: 0).use
  @browser.link(href: /user-profile/).wait_until(&:present?).click
  @browser.file_field(:name => 'avatar').set("files/flag.jpg")
  @browser.window(index: 1).wait_until(&:exists?)
  @browser.window(title: 'Superhero Wallet').use
  @browser.button(text: 'Confirm').wait_until(&:present?).wait_until(&:enabled?).double_click
end

def test_002_add_comments
  puts "tbd"
end

def test_003_allow_youtube_cookies

  # example define all elements at one place first (very basic example/concept of PageObject)
  search_box = @browser.text_field(placeholder: 'Search Superhero')
  play_button = @browser.button(class: /play-button/)
  cookies_button = @browser.button(class: /cookies-button/)
  article_content = @browser.div(class: /tip__article__content/)
  article_content.wait_until(&:present?)
  youtube_iframe = @browser.iframe(src: /youtube-nocookie.com/)

  # test section
  local_storage = get_vuex_local_storage
  assert(search_box.exists?,'Search box is not present')
  search_box.set('#minimal youtube')
  sleep 3
  play_button.wait_until(&:present?).double_click
  cookies_button.wait_until(&:present?)
  assert(cookies_button.exists?, 'Allow Cookies button is not present')
  cookies_button.click
  cookies_button.wait_while(&:present?)
  updated_local_storage = get_vuex_local_storage
  assert(local_storage != updated_local_storage)
  play_button.wait_until(&:present?).wait_until(&:enabled?).click
  youtube_iframe.button(class: /ytp-play-button/).wait_until(&:present?)
  sleep 0.5
  $extension == 'true' ? (youtube_iframe.button(class: /ytp-play-button/).wait_until(&:enabled?).double_click) : (youtube_iframe.button(class: /ytp-play-button/).wait_until(&:enabled?).click)
  sleep 10 #lets hear for some music
end

def test_004_install_superhero_extension
  @browser.goto SuperHero::WALLET_URL
   if $extension == 'true'
  @browser.span(class: 'checkmark').wait_until(&:present?).click
  @browser.button(text: "Generate New Wallet").wait_until(&:enabled?).click
  @browser.div(class: "dotstyle").wait_until(&:present?)
  @browser.button(text: "Skip").wait_until(&:present?).click
  @browser.button(text: "Generate Wallet").wait_until(&:enabled?).click
  @browser.button(text: "Proceed to your Wallet").wait_until(&:enabled?).click
  sleep 5
   else
     @browser.img(src: /chrome/).wait_until(&:present?).click(:command, :shift)
   end
end

 def teardown
   @browser.close
 end
end

require 'base64'
require 'json'
require 'net/http'

module TwoCaptcha
  # Create a TwoCaptcha API client. This is a shortcut to
  # TwoCaptcha::Client.new.
  #
  def self.new(*args)
    ZeroCaptcha::Client.new(*args)
  end
end

require 'two_captcha/client'
require 'two_captcha/errors'
require 'two_captcha/http'
require 'two_captcha/models/captcha'
require "two_captcha/version"

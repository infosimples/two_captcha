require 'base64'
require 'json'
require 'net/http'

# The module TwoCaptcha contains all the code for the two_captcha gem.
# It acts as a safely namespace that isolates logic from TwoCaptcha from any
# project that uses it.
#
module TwoCaptcha
  # Instantiate TwoCaptcha API client. This is a shortcut to
  # TwoCaptcha::Client.new
  #
  def self.new(key, options = {})
    TwoCaptcha::Client.new(key, options)
  end

  # Base class of a model object returned by TwoCaptcha API.
  #
  class Model
    def initialize(values = {})
      values.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end
end

require 'two_captcha/client'
require 'two_captcha/errors'
require 'two_captcha/http'
require 'two_captcha/models/captcha'
require 'two_captcha/version'

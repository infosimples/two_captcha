require 'base64'
require 'json'
require 'net/http'

module TwoCaptcha
  # Instantiate TwoCaptcha API client. This is a shortcut to
  # TwoCaptcha::Client.new
  #
  def self.new(token, options = {})
    TwoCaptcha::Client.new(token, options)
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

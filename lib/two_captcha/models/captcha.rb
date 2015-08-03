module TwoCaptcha
  # Model of a Captcha returned by ZeroCaptcha API.
  #
  class Captcha < TwoCaptcha::Model
    attr_accessor :id, :text, :code, :correct, :duration_in_milliseconds,
                  :created_at, :created_at_not_parsed

    alias_method :correct?, :correct
    alias_method :duration, :duration_in_milliseconds
  end
end

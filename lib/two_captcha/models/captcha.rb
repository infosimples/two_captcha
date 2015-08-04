module TwoCaptcha
  # Model of a Captcha returned by ZeroCaptcha API.
  #
  class Captcha < TwoCaptcha::Model
    attr_accessor :id, :text
  end
end

module TwoCaptcha
  # Model of a Captcha returned by ZeroCaptcha API.
  #
  class Captcha < TwoCaptcha::Model
    attr_accessor :id, :text, :cost, :api_response

    def indexes
      text.gsub('click:', '').split(/[^0-9]/).map(&:to_i)
    end
  end
end

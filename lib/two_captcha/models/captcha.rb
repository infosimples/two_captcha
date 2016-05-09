module TwoCaptcha
  # Model of a Captcha returned by ZeroCaptcha API.
  #
  class Captcha < TwoCaptcha::Model
    attr_accessor :id, :text, :api_response

    def indexes
      text.gsub('click:', '').split(/[^0-9]/).map(&:to_i)
    end

    def coordinates
      text.scan(/x=([0-9]+),y=([0-9]+)/).map { |x, y| [x.to_i, y.to_i] }
    end
  end
end

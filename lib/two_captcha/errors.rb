module TwoCaptcha
  # This is the base TwoCaptcha exception class. Rescue it if you want to
  # catch any exception that might be raised.
  #
  class Error < Exception
  end

  class ArgumentError < Error
  end

  class InvalidCaptcha < Error
    def initialize
      super('The captcha is empty or invalid')
    end
  end

  class InvalidCaptchaType < Error
    def initialize
      super('Captcha type is invalid or cannot be solved by TwoCaptcha')
    end
  end

  class Timeout < Error
    def initialize
      super('The captcha was not solved in the expected time')
    end
  end

  class IncorrectSolution < Error
    def initialize
      super('The captcha could not be solved correctly')
    end
  end

  class APIForbidden < Error
    def initialize
      super('Access denied, please check your credentials and/or balance')
    end
  end

  class APIBadRequest < Error
    def initialize
      super('The Captcha was rejected, check if it\'s a valid image')
    end
  end

  class APIResponseError < Error
    def initialize(info)
      super("Invalid API response: #{info}")
    end
  end
end

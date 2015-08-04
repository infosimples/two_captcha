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

  class WrongUserKey < Error
    def initialize
      super('Wrong “key” parameter format, it should contain 32 symbols')
    end
  end

  class InvalidUserKey < Error
    def initialize
      super('The “key” doesn’t exist')
    end
  end

  class ZeroBalance < Error
    def initialize
      super('You don’t have enought money on your account')
    end
  end

  class NoSlotAvailable < Error
    def initialize
      super('The current bid is higher than the maximum bid set for your account.')
    end
  end

  class SmallCaptchaFilesize < Error
    def initialize
      super('CAPTCHA size is less than 100 bytes')
    end
  end

  class BigCaptchaFilesize < Error
    def initialize
      super('CAPTCHA size is more than 100 Kbytes')
    end
  end

  class WrongFileExtension < Error
    def initialize
      super('The CAPTCHA has a wrong extension. Possible extensions are: jpg,jpeg,gif,png')
    end
  end

  class ImageNotSupported < Error
    def initialize
      super('The server cannot recognize the CAPTCHA file type')
    end
  end

  class IpNotAllowed < Error
    def initialize
      super('The request has sent from the IP that is not on the list of your IPs. Check the list of your IPs in the system')
    end
  end

  class IpBanned < Error
    def initialize
      super('The IP address you\'re trying to access our server with is banned due to many frequent attempts to access the server using wrong authorization keys. To lift the ban, please, contact our support team via email: support@2captcha.com')
    end
  end

  class WrongIdFormat < Error
    def initialize
      super('Wrong format ID CAPTCHA. ID must contain only numbers')
    end
  end

  class CaptchaUnsolvable < Error
    def initialize
      super('Captcha could not solve three different employee. Funds for this captcha not')
    end
  end

  class EmptyAction < Error
    def initialize
      super('No action passed')
    end
  end

  class NotReported < Error
    def initialize
      super('Could not report. Please, contact our support team via email: support@2captcha.com')
    end
  end

  class Timeout < Error
    def initialize
      super('The captcha was not solved in the expected time')
    end
  end
end

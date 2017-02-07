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

  class Timeout < Error
    def initialize
      super('The captcha was not solved in the expected time')
    end
  end

  class GoogleKey < Error
    def initialize
      super('Missing googlekey parameter')
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

  class CaptchaImageBlocked < Error
    def initialize
      super('You have sent an image, that is unrecognizable and which is saved in our database as such. Usually this happens when the site where you get the captcha from has stopped sending you captcha and started giving you a “deny access” cap.')
    end
  end

  class WrongCaptchaId < Error
    def initialize
      super('You are trying to get the answer or complain a captcha that was submitted more than 15 minutes ago.')
    end
  end

  class BadDuplicates < Error
    def initialize
      super('Error is returned when 100% accuracy feature is enabled. The error means that max numbers of tries is reached but min number of matches not found.')
    end
  end

  class ReportNotRecorded < Error
    def initialize
      super('Error is returned to your complain request (reportbad) if you already complained lots of correctly solved captchas.')
    end
  end

  RESPONSE_ERRORS = {
    'ERROR_WRONG_USER_KEY'           => TwoCaptcha::WrongUserKey,
    'ERROR_KEY_DOES_NOT_EXIST'       => TwoCaptcha::InvalidUserKey,
    'ERROR_ZERO_BALANCE'             => TwoCaptcha::ZeroBalance,
    'ERROR_NO_SLOT_AVAILABLE'        => TwoCaptcha::NoSlotAvailable,
    'ERROR_ZERO_CAPTCHA_FILESIZE'    => TwoCaptcha::SmallCaptchaFilesize,
    'ERROR_TOO_BIG_CAPTCHA_FILESIZE' => TwoCaptcha::BigCaptchaFilesize,
    'ERROR_WRONG_FILE_EXTENSION'     => TwoCaptcha::WrongFileExtension,
    'ERROR_IMAGE_TYPE_NOT_SUPPORTED' => TwoCaptcha::ImageNotSupported,
    'ERROR_IP_NOT_ALLOWED'           => TwoCaptcha::IpNotAllowed,
    'IP_BANNED'                      => TwoCaptcha::IpBanned,
    'ERROR_WRONG_ID_FORMAT'          => TwoCaptcha::WrongIdFormat,
    'ERROR_CAPTCHA_UNSOLVABLE'       => TwoCaptcha::CaptchaUnsolvable,
    'ERROR_EMPTY_ACTION'             => TwoCaptcha::EmptyAction,
    'ERROR_GOOGLEKEY'                => TwoCaptcha::GoogleKey,
    'ERROR_CAPTCHAIMAGE_BLOCKED'     => TwoCaptcha::CaptchaImageBlocked,
    'ERROR_WRONG_CAPTCHA_ID'         => TwoCaptcha::WrongCaptchaId,
    'ERROR_BAD_DUPLICATES'           => TwoCaptcha::BadDuplicates,
    'REPORT_NOT_RECORDED'            => TwoCaptcha::ReportNotRecorded,
  }
end

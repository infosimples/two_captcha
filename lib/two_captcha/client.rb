module TwoCaptcha
  # TwoCaptcha::Client is a client that communicates with the TwoCaptcha API:
  # https://twocaptcha.infosimples.com/.
  #
  class Client
    attr_accessor :token, :timeout, :pooling, :phrase, :regsense, :numeric,
                  :calc, :min_len, :max_len

    # Create a TwoCaptcha API client.
    #
    # @param [String] token Token of the TwoCaptcha account.
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up of a
    #                                         captcha being solved.
    # @option options [Integer] :pooling  (5) Seconds before check_answer again
    # @option options [Integer] :phrase   (0) 0: 1 word
    #                                         1: CAPTCHA contains 2 words
    # @option options [Integer] :regsense (0) 0: not case sensitive
    #                                         1: case sensitive
    # @option options [Integer] :numeric  (0) 0: not specified
    #                                         1: numeric CAPTCHA
    #                                         2: letters CAPTCHA
    #                                         3: either numeric or letters
    # @option options [Integer] :calc     (0) 0: not specified
    #                                         1: math CAPTCHA
    # @option options [Integer] :min_len  (0) 0: not specified
    #                                         1..20: minimal number of symbols
    #                                                in the CAPTCHA text
    # @option options [Integer] :max_len  (0) 0: not specified
    #                                         1..20: maximum number of symbols
    #                                                in the CAPTCHA text
    #
    # @return [TwoCaptcha::Client] A Client instance.
    #
    def initialize(token, options = {})
      self.token    = token
      self.timeout  = options[:timeout] || 60
      self.pooling  = options[:pooling] || 5
      self.phrase   = options[:phrase]   if options[:phrase]
      self.regsense = options[:regsense] if options[:regsense]
      self.numeric  = options[:numeric]  if options[:numeric]
      self.calc     = options[:calc]     if options[:calc]
      self.min_len  = options[:min_len]  if options[:min_len]
      self.max_len  = options[:max_len]  if options[:max_len]
    end

    # Decode the text from an image (i.e. solve a captcha).
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url   URL of the image to be decoded.
    # @option options [String]  :path  File path of the image to be decoded.
    # @option options [File]    :file  File instance with image to be decoded.
    # @option options [String]  :raw   Binary content of the image to be
    #                                  decoded.
    # @option options [String]  :raw64 Binary content encoded in base64 of the
    #                                  image to be decoded.
    #
    # @return [TwoCaptcha::Captcha] The captcha (with solution) or an empty
    #                                hash if something goes wrong.
    #
    def decode(options = {})
      decode!(options)
    rescue TwoCaptcha::Error => ex
      puts ex
      TwoCaptcha::Captcha.new
    end

    # Decode the text from an image (i.e. solve a captcha).
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url   URL of the image to be decoded.
    # @option options [String]  :path  File path of the image to be decoded.
    # @option options [File]    :file  File instance with image to be decoded.
    # @option options [String]  :raw   Binary content of the image to be
    #                                  decoded.
    # @option options [String]  :raw64 Binary content encoded in base64 of the
    #                                  image to be decoded.
    #
    # @return [TwoCaptcha::Captcha] The captcha (with solution) if an error
    #                                is not raised.
    #
    def decode!(options = {})
      started_at = Time.now

      raw64   = load_captcha(options)
      fail(TwoCaptcha::InvalidCaptcha) if raw64.to_s.empty?

      res = parse_response(TwoCaptcha::HTTP.upload(raw64, token))

      raise_error(res[:message]) if res[:status] == 'ERROR'

      response = {}

      loop do
        response = parse_response(TwoCaptcha::HTTP.check_answer(res[:message],
                                                                token))
        if response[:message] == 'CAPCHA_NOT_READY'
          sleep(pooling)
          fail(TwoCaptcha::Timeout) if (Time.now - started_at) > timeout
        else
          raise_error(response[:message]) if response[:status] == 'ERROR'
          break
        end
      end

      Captcha.new(status: response[:status],
                  id: res[:message],
                  text: response[:message])
    end

    # Parse response from requests
    #
    # @param [String] response The response from TwoCaptcha API.
    #
    # @return [Hash] Parsed response with status, id and text
    #

    def parse_response(response)
      res = response.split('|')
      if res[0] == 'OK'
        { status: 'OK', message: res[1] }
      else
        { status: 'ERROR', message: res[0] }
      end
    end

    # Parse response from requests
    #
    # @param [String] response The response from TwoCaptcha API.
    #
    # @return [Hash] Parsed response with status and message
    #

    def raise_error(response)
      case response
      when 'ERROR_WRONG_USER_KEY'
        fail(TwoCaptcha::WrongUserKey)
      when 'ERROR_KEY_DOES_NOT_EXIST'
        fail(TwoCaptcha::InvalidUserKey)
      when 'ERROR_ZERO_BALANCE'
        fail(TwoCaptcha::ZeroBalance)
      when 'ERROR_NO_SLOT_AVAILABLE'
        fail(TwoCaptcha::NoSlotAvailable)
      when 'ERROR_ZERO_CAPTCHA_FILESIZE'
        fail(TwoCaptcha::SmallCaptchaFilesize)
      when 'ERROR_TOO_BIG_CAPTCHA_FILESIZE'
        fail(TwoCaptcha::BigCaptchaFilesize)
      when 'ERROR_WRONG_FILE_EXTENSION'
        fail(TwoCaptcha::WrongFileExtension)
      when 'ERROR_IMAGE_TYPE_NOT_SUPPORTED'
        fail(TwoCaptcha::ImageNotSupported)
      when 'ERROR_IP_NOT_ALLOWED'
        fail(TwoCaptcha::IpNotAllowed)
      when 'IP_BANNED'
        fail(TwoCaptcha::IpBanned)
      when 'ERROR_WRONG_ID_FORMAT'
        fail(TwoCaptcha::WrongIdFormat)
      when 'ERROR_CAPTCHA_UNSOLVABLE'
        fail(TwoCaptcha::CaptchaUnsolvable)
      when 'ERROR_EMPTY_ACTION'
        fail(TwoCaptcha::EmptyAction)
      end
    end

    # TODO: Implement report
    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] id Numeric ID of the captcha.
    #
    # @return [TwoCaptcha::Captcha] The captcha with current "correct" value.
    #
    # def report_incorrect(id)
    #   # response = report('report_incorrect', id: id)
    #   # TwoCaptcha::Captcha.new(response)
    # end

    # TODO: Implement getStats
    # TODO: Implement getBalance

    private

    # Load a captcha raw content encoded in base64 from options.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url   URL of the image to be decoded.
    # @option options [String]  :path  File path of the image to be decoded.
    # @option options [File]    :file  File instance with image to be decoded.
    # @option options [String]  :raw   Binary content of the image to bedecoded.
    # @option options [String]  :raw64 Binary content encoded in base64 of the
    #                                  image to be decoded.
    #
    # @return [String] The binary image base64 encoded.
    #
    def load_captcha(options)
      if options[:raw64]
        options[:raw64]
      elsif options[:raw]
        Base64.encode64(options[:raw])
      elsif options[:file]
        Base64.encode64(options[:file].read)
      elsif options[:path]
        Base64.encode64(File.open(options[:path], 'rb').read)
      elsif options[:url]
        Base64.encode64(TwoCaptcha::HTTP.open_url(options[:url]))
      else
        fail TwoCaptcha::ArgumentError, 'Illegal image format'
      end
    rescue
      raise TwoCaptcha::InvalidCaptcha
    end
  end
end

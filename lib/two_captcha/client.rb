module TwoCaptcha
  # TwoCaptcha::Client is a client that communicates with the TwoCaptcha API:
  # https://zerocaptcha.infosimples.com/.
  #
  class Client
    BASE_URL = 'https://zerocaptcha.infosimples.com/api/v1/captcha/:action.json'

    attr_accessor :token, :timeout

    # Create a TwoCaptcha API client.
    #
    # @param [String] token Token of the TwoCaptcha account.
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up of a
    #                                         captcha being solved.
    #
    # @return [TwoCaptcha::Client] A Client instance.
    #
    def initialize(token, options = {})
      self.token      = token
      self.timeout    = options[:timeout] || 60
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
    rescue TwoCaptcha::Error
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
      raw64   = load_captcha(options)
      solver  = options[:solver]

      response = request(solver, :multipart, image64: raw64)
      captcha = TwoCaptcha::Captcha.new(response)

      fail(TwoCaptcha::IncorrectSolution) unless captcha.correct?

      captcha
    end

    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] id Numeric ID of the captcha.
    #
    # @return [TwoCaptcha::Captcha] The captcha with current "correct" value.
    #
    def report_incorrect(id)
      response = request('report_incorrect', :post, id: id)
      TwoCaptcha::Captcha.new(response)
    end

    # Report correctly solved captcha for statistics.
    #
    # @param [Integer] id Numeric ID of the captcha.
    #
    # @return [TwoCaptcha::Captcha] The captcha with current "correct" value.
    #
    def report_correct(id)
      response = request('report_correct', :post, id: id)
      TwoCaptcha::Captcha.new(response)
    end

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

    # Perform an HTTP request to the TwoCaptcha API.
    #
    # @param [String] action  API method name.
    # @param [Symbol] method  HTTP method (:get, :post, :multipart).
    # @param [Hash]   payload Data to be sent through the HTTP request.
    #
    # @return [Hash] Response from the TwoCaptcha API.
    #
    def request(action, method = :get, payload = {})
      res = TwoCaptcha::HTTP.request(
        url: BASE_URL.gsub(':action', action),
        timeout: timeout,
        method: method,
        payload: payload.merge(token: token)
      )
      JSON.parse(res)
    end
  end
end

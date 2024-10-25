module TwoCaptcha
  # TwoCaptcha::Client is a client that communicates with the TwoCaptcha API:
  # https://2captcha.com/.
  #
  class Client
    BASE_URL = 'http://2captcha.com/:action.php'

    attr_accessor :key, :timeout, :polling

    # Create a TwoCaptcha API client.
    #
    # @param [String] Captcha key of the TwoCaptcha account.
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up of a
    #                                         captcha being solved.
    # @option options [Integer] :polling  (5) Seconds before check_answer again
    #
    # @return [TwoCaptcha::Client] A Client instance.
    #
    def initialize(key, options = {})
      self.key     = key
      self.timeout = options[:timeout] || 60
      self.polling = options[:polling] || 5
    end

    # Decode the text from an image (i.e. solve a captcha).
    #
    # @param [Hash] options Options hash. Check docs for the method decode!.
    #
    # @return [TwoCaptcha::Captcha] The captcha (with solution) or an empty
    #                               captcha instance if something goes wrong.
    #
    def decode_image(options = {})
      decode_image!(options)
    rescue TwoCaptcha::Error => ex
      TwoCaptcha::Captcha.new
    end
    alias :decode :decode_image

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
    # @option options [Integer] :phrase         (0) https://2captcha.com/setting
    # @option options [Integer] :regsense       (0) https://2captcha.com/setting
    # @option options [Integer] :numeric        (0) https://2captcha.com/setting
    # @option options [Integer] :calc           (0) https://2captcha.com/setting
    # @option options [Integer] :min_len        (0) https://2captcha.com/setting
    # @option options [Integer] :max_len        (0) https://2captcha.com/setting
    # @option options [Integer] :language       (0) https://2captcha.com/setting
    # @option options [Integer] :header_acao    (0) https://2captcha.com/setting
    # @option options [Integer] :id_constructor (0) 23 if new reCAPTCHA.
    # @option options [Integer] :coordinatescaptcha (0) 1 if clickable captcha.
    #
    # @return [TwoCaptcha::Captcha] The captcha (with solution) if an error is
    #                               not raised.
    #
    def decode_image!(options = {})
      started_at = Time.now

      raw64 = load_captcha(options)
      fail(TwoCaptcha::InvalidCaptcha) if raw64.to_s.empty?

      decoded_captcha = upload(options.merge(raw64: raw64))

      # pool untill the answer is ready
      while decoded_captcha.text.to_s.empty?
        sleep(polling)
        decoded_captcha = captcha(decoded_captcha.id)
        fail TwoCaptcha::Timeout if (Time.now - started_at) > timeout
      end

      decoded_captcha
    end
    alias :decode! :decode_image!

    #
    # Solve reCAPTCHA v2.
    #
    # @param [Hash] options Options hash. Check docs for the method decode!.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_recaptcha_v2(options = {})
      decode_recaptcha_v2!(options)
    rescue TwoCaptcha::Error => ex
      TwoCaptcha::Captcha.new
    end

    #
    # Solve reCAPTCHA v2.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :googlekey The open key of the site in which recaptcha is installed.
    # @option options [String]  :pageurl The URL of the page where the recaptcha is present.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_recaptcha_v2!(options = {})
      started_at = Time.now

      fail(TwoCaptcha::GoogleKey) if options[:googlekey].empty?

      upload_options = { method: 'userrecaptcha' }.merge(options)
      decoded_captcha = upload(upload_options)

      # pool untill the answer is ready
      while decoded_captcha.text.to_s.empty?
        sleep([polling, 10].max) # sleep at least 10 seconds
        decoded_captcha = captcha(decoded_captcha.id)
        fail TwoCaptcha::Timeout if (Time.now - started_at) > timeout
      end

      decoded_captcha
    end

    #
    # Solve reCAPTCHA v3.
    #
    # @param [Hash] options Options hash. Check docs for the method decode!.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_recaptcha_v3(options = {})
      decode_recaptcha_v3!(options)
    rescue TwoCaptcha::Error => ex
      TwoCaptcha::Captcha.new
    end

    #
    # Solve reCAPTCHA v3.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :googlekey The open key of the site in which recaptcha is installed.
    # @option options [String]  :pageurl The URL of the page where the recaptcha is present.
    # @option options [String]  :action The action paramenter present on the page that uses recaptcha.
    # @option options [String]  :min_score The minimum score necessary to pass the challenge.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_recaptcha_v3!(options = {})
      started_at = Time.now

      fail(TwoCaptcha::GoogleKey) if options[:googlekey].empty?

      upload_options = {
        method:  'userrecaptcha',
        version: 'v3',
      }.merge(options)
      decoded_captcha = upload(upload_options)

      # pool untill the answer is ready
      while decoded_captcha.text.to_s.empty?
        sleep([polling, 10].max) # sleep at least 10 seconds
        decoded_captcha = captcha(decoded_captcha.id)
        fail TwoCaptcha::Timeout if (Time.now - started_at) > timeout
      end

      decoded_captcha
    end

    #
    # Solve hCaptcha.
    #
    # @param [Hash] options Options hash. Check docs for the method decode_hcaptcha!.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_hcaptcha(options = {})
      decode_hcaptcha!(options)
    rescue TwoCaptcha::Error => ex
      TwoCaptcha::Captcha.new
    end

    #
    # Solve hCaptcha.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :sitekey The  key of the site in which hCaptcha is installed.
    # @option options [String]  :pageurl The URL of the page where the hCaptcha is present.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_hcaptcha!(options = {})
      started_at = Time.now

      fail(TwoCaptcha::SiteKey) if options[:sitekey].empty?

      upload_options = { method: 'hcaptcha' }.merge(options)
      decoded_captcha = upload(upload_options)

      # pool untill the answer is ready
      while decoded_captcha.text.to_s.empty?
        sleep([polling, 10].max) # sleep at least 10 seconds
        decoded_captcha = captcha(decoded_captcha.id)
        fail TwoCaptcha::Timeout if (Time.now - started_at) > timeout
      end

      decoded_captcha
    end

    # Solve Amazon WAF.
    #
    # @param [Hash] options Options hash. Check docs for the method decode_amazon_waf!.
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_amazon_waf(options = {})
      decode_amazon_waf!(opt)
    rescue TwoCaptcha::Error => ex
      TwoCaptcha::Captcha.new
    end

    #
    # Solve Amazon WAF.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :sitekey The  key of the site in which Amazon WAF is installed.
    # @option options [String]  :pageurl The URL of the page where the Amazon WAF is present.
    # @option options [String]  :iv The value of the `iv` parameter found on the page.
    # @option options [String]  :context The value of the `context` parameter found on the page.
    # @option options [String]  :challenge_script The source URL of challenge.js script on the page.
    # @option options [String]  :captcha_script The source URL of captcha.js script on the page
    #
    # @return [TwoCaptcha::Captcha] The solution of the given captcha.
    #
    def decode_amazon_waf!(options = {})
      started_at = Time.now

      fail(TwoCaptcha::ArgumentError) if options[:sitekey].empty? || options[:pageurl].empty? || options[:iv].empty? || options[:context].empty?

      upload_options = { method: 'amazon_waf' }.merge(options)
      decoded_captcha = upload(upload_options)

      # pool untill the answer is ready
      while decoded_captcha.text.to_s.empty?
        sleep([polling, 10].max) # sleep at least 10 seconds
        decoded_captcha = captcha(decoded_captcha.id)
        fail TwoCaptcha::Timeout if (Time.now - started_at) > timeout
      end

      decoded_captcha
    end

    # Upload a captcha to 2Captcha.
    #
    # This method will not return the solution. It helps on separating concerns.
    #
    # @return [TwoCaptcha::Captcha] The captcha object (not solved yet).
    #
    def upload(options = {})
      args = {}
      args[:body]   = options[:raw64] if options[:raw64]
      args[:method] = options[:method] || 'base64'
      args.merge!(options)
      response = request('in', :multipart, args)

      unless response.match(/\AOK\|/)
        fail(TwoCaptcha::Error, 'Unexpected API Response')
      end

      TwoCaptcha::Captcha.new(
        id: response.split('|', 2)[1],
        api_response: response
      )
    end

    # Retrieve information from an uploaded captcha.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [TwoCaptcha::Captcha] The captcha object.
    #
    def captcha(captcha_id)
      response = request('res', :get, action: 'get', id: captcha_id)

      decoded_captcha = TwoCaptcha::Captcha.new(id: captcha_id)
      decoded_captcha.api_response = response

      if response.match(/\AOK\|/)
        decoded_captcha.text = response.split('|', 2)[1]
      end

      decoded_captcha
    end

    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] id Numeric ID of the captcha.
    # @param [Integer] action 'reportbad' (default) or 'reportgood'.
    #
    # @return [Boolean] true if correctly reported
    #
    def report!(captcha_id, action = 'reportbad')
      response = request('res', :get, action: action, id: captcha_id)
      response == 'OK_REPORT_RECORDED'
    end

    # Get balance from your account.
    #
    # @return [Float] Balance in USD.
    #
    def balance
      request('res', :get, action: 'getbalance').to_f
    end

    # Get statistics from your account.
    #
    # @param [Date] date Date when the statistics were collected.
    #
    # @return [String] Statistics from date in an XML string.
    #
    def stats(date)
      request('res', :get, action: 'getstats', date: date.strftime('%Y-%m-%d'))
    end

    # Get current load from 2Captcha.
    #
    # @return [String] Load in an XML string.
    #
    def load
      request('load', :get)
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

    # Perform an HTTP request to the 2Captcha API.
    #
    # @param [String] action  API method name.
    # @param [Symbol] method  HTTP method (:get, :post, :multipart).
    # @param [Hash]   payload Data to be sent through the HTTP request.
    #
    # @return [String] Response from the TwoCaptcha API.
    #
    def request(action, method = :get, payload = {})
      res = TwoCaptcha::HTTP.request(
        url: BASE_URL.gsub(':action', action),
        timeout: timeout,
        method: method,
        payload: payload.merge(key: key, soft_id: 800)
      )
      validate_response(res)
      res
    end

    # Fail if the response has errors.
    #
    # @param [String] response The body response from TwoCaptcha API.
    #
    def validate_response(response)
      if (error = TwoCaptcha::RESPONSE_ERRORS[response])
        fail(error)
      elsif response.to_s.empty? || response.match(/\AERROR\_/)
        fail(TwoCaptcha::Error, response)
      end
    end
  end
end

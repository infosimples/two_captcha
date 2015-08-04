module TwoCaptcha
  # TwoCaptcha::HTTP exposes common HTTP routines that can be used by the
  # TwoCaptcha API client.
  #
  class HTTP
    BASE_URL = 'http://2captcha.com'

    # Retrieve the contents of a captcha URL supporting HTTPS and redirects.
    #
    # @param [String] url The captcha URL.
    #
    # @return [String] The contents of the captcha URL.
    #
    def self.open_url(url)
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      res = http.get(uri.request_uri)

      if (redirect = res.header['location'])
        open_url(redirect)
      else
        res.body
      end
    end

    # Perform an HTTP request to the TwoCaptcha API.
    #
    # @param [String] action  API method name.
    # @param [Symbol] method  HTTP method (:get, :post).
    # @param [Hash]   payload Data to be sent through the HTTP request.
    #
    # @return [Hash] Response from the TwoCaptcha API.
    #

    def self.request(method = :get, payload = {})
      headers = { 'User-Agent' => TwoCaptcha::USER_AGENT }
      if method == :post
        uri = URI("#{BASE_URL}/in.php")
        req = Net::HTTP::Post.new(uri.request_uri, headers)
        req.set_form_data(payload)
      else
        uri = URI("#{BASE_URL}/res.php?#{URI.encode_www_form(payload)}")
        req = Net::HTTP::Get.new(uri.request_uri, headers)
      end

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      res.body
    end
  end
end

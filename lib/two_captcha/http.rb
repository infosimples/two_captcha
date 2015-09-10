module TwoCaptcha
  # TwoCaptcha::HTTP exposes common HTTP routines that can be used by the
  # TwoCaptcha API client.
  #
  class HTTP
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

    # Perform an HTTP request with support to multipart requests.
    #
    # @param [Hash] options Options hash.
    # @param options [String] url      URL to be requested.
    # @param options [Symbol] method   HTTP method (:get, :post, :multipart).
    # @param options [Hash]   payload  Data to be sent through the HTTP request.
    # @param options [Integer] timeout HTTP open/read timeout in seconds.
    #
    # @return [String] Response body of the HTTP request.
    #
    def self.request(options = {})
      uri     = URI(options[:url])
      method  = options[:method] || :get
      payload = options[:payload] || {}
      timeout = options[:timeout] || 60
      headers = { 'User-Agent' => TwoCaptcha::USER_AGENT }

      case method
      when :get
        uri.query = URI.encode_www_form(payload)
        req = Net::HTTP::Get.new(uri.request_uri, headers)

      when :post
        req = Net::HTTP::Post.new(uri.request_uri, headers)
        req.set_form_data(payload)

      when :multipart
        req = Net::HTTP::Post.new(uri.request_uri, headers)
        boundary, body = prepare_multipart_data(payload)
        req.content_type = "multipart/form-data; boundary=#{boundary}"
        req.body = body

      else
        fail TwoCaptcha::ArgumentError, "Illegal HTTP method (#{method})"
      end

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true if (uri.scheme == 'https')
      http.open_timeout = timeout
      http.read_timeout = timeout
      res = http.request(req)
      res.body

    rescue Net::OpenTimeout, Net::ReadTimeout
      raise TwoCaptcha::Timeout
    end

    # Prepare the multipart data to be sent via a :multipart request.
    #
    # @param [Hash] payload Data to be prepared via a multipart post.
    #
    # @return [String, String] Boundary and body for the multipart post.
    #
    def self.prepare_multipart_data(payload)
      boundary = 'randomstr' + rand(1_000_000).to_s # a random unique string

      content = []
      payload.each do |param, value|
        content << '--' + boundary
        content << "Content-Disposition: form-data; name=\"#{param}\""
        content << ''
        content << value
      end
      content << '--' + boundary + '--'
      content << ''

      [boundary, content.join("\r\n")]
    end
  end
end

# TwoCaptcha

TwoCaptcha is a Ruby API for 2Captcha - [2Captcha.com](http://2captcha.com/?from=1025109)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'two_captcha'
```

And then execute:

```bash
$ bundle
````

Or install it yourself as:

```bash
$ gem install two_captcha
````

## Usage

### 1. Create a client

```ruby
client = TwoCaptcha.new('my_key')
```

### 2. Solve a CAPTCHA

There are two types of methods available: `decode` and `decode!`:

- `decode` does not raise exceptions.
- `decode!` may raise a `TwoCaptcha::Error` if something goes wrong.

If the solution is not available, an empty solution object will be returned.

```ruby
captcha = client.decode_image!(url: 'http://bit.ly/1xXZcKo')
captcha.text        # CAPTCHA solution
captcha.id          # CAPTCHA numeric id
```

#### Image CAPTCHA

You can specify `file`, `path`, `raw`, `raw64` and `url` when decoding an image.

```ruby
client.decode_image!(file: File.open('path/to/my/captcha/file', 'rb'))
client.decode_image!(path: 'path/to/my/captcha/file')
client.decode_image!(raw: File.open('path/to/my/captcha/file', 'rb').read)
client.decode_image!(raw64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
client.decode_image!(url: 'http://bit.ly/1xXZcKo')
```

You may also specify any POST parameters specified at https://2captcha.com/setting.

#### reCAPTCHA v2

```ruby
captcha = client.decode_recaptcha_v2!(
  googlekey: 'xyz',
  pageurl:   'http://example.com/example=1',
)

# The response will be a text (token), which you can access with the `text` method.

captcha.text
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `googlekey`: the Google key for the reCAPTCHA.
- `pageurl`: the URL of the page with the reCAPTCHA challenge.


#### reCAPTCHA v3

```ruby
captcha = client.decode_recaptcha_v3!(
  googlekey: 'xyz',
  pageurl:   'http://example.com/example=1',
  action:    'verify',
  min_score: 0.3, # OPTIONAL
)

# The response will be a text (token), which you can access with the `text` method.

captcha.text
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `googlekey`: the Google key for the reCAPTCHA.
- `pageurl`: the URL of the page with the reCAPTCHA challenge.
- `action`: the action name used by the CAPTCHA.
- `min_score`: optional parameter. The minimal score needed for the CAPTCHA resolution. Defaults to `0.3`.

> About the `action` parameter: in order to find out what this is, you need to inspect the JavaScript
> code of the website looking for a call to the `grecaptcha.execute` function.
>
> ```javascript
> // Example
> grecaptcha.execute('6Lc2fhwTAAAAAGatXTzFYfvlQMI2T7B6ji8UVV_f', { action: "examples/v3scores" })
> ````

> About the `min_score` parameter: it's strongly recommended to use a minimum score of `0.3` as higher
> scores are rare.

#### hCaptcha

```ruby
captcha = client.decode_hcaptcha!(
  sitekey: 'xyz',
  pageurl: 'http://example.com/example=1',
)

captcha.text
"P0_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXNza2V5IjoiNnpWV..."
```

#### Amazon WAF

```ruby
captcha = client.decode_amazon_waf!(
  sitekey:          'xyz',
  pageurl:          'http://example.com/example=1',
  iv:               'A1A1A1A1A1A1A1A1',
  context:          'ABcd...',
  challenge_script: 'http://example.com/challenge.js',
)

puts captcha.text
{"captcha_voucher":"eyJ0...","existing_token":"f2ae6..."}
```

*Parameters:*

- `website_key`: the site key for the hCatpcha.
- `website_url`: the URL of the page with the hCaptcha challenge.

### 3. Using proxy or other custom options

You are allowed to use custom options like `proxy`, `proxytype` or `userAgent` whenever the
2Captcha API supports it. Example:

  ```ruby
  options = {
    sitekey:   'xyz',
    pageurl:   'http://example.com/example=1',
    proxy:     'login:password@123.123.123.123:3128',
    userAgent: 'user agent',
  }

  captcha = client.decode_hcaptcha!(options)
  ```

### 4. Retrieve a previously solved CAPTCHA

```ruby
captcha = client.captcha('130920620') # with 130920620 being the CAPTCHA id
```

### 5. Report an incorrectly solved CAPTCHA for a refund

```ruby
client.report!('130920620', 'reportbad') # with 130920620 being the CAPTCHA id
# returns `true` if successfully reported

client.report!('256892751', 'reportgood') # with 256892751 being the CAPTCHA id
# returns `true` if successfully reported
```

### 6. Get your account balance

```ruby
client.balance
# returns a Float balance in USD.
```

### 7. Get usage statistics for a specific date

```ruby
client.stats(Date.new(2022, 10, 7))
# returns an XML string with your usage statistics.
```

## Notes

### Thread-safety

The API is thread-safe, which means it is perfectly fine to share a client
instance between multiple threads.

### Ruby dependencies

TwoCaptcha don't require specific dependencies. That saves you memory and
avoid conflicts with other gems.

### Input image format

Any format you use in the `decode_image!` method (`url`, `file`, `path`, `raw` or `raw64`)
will always be converted to a `raw64`, which is a base64-encoded binary string.
So, if you already have this format on your end, there is no need for convertions
before calling the API.

> Our recomendation is to never convert your image format, unless needed. Let
> the gem convert internally. It may save you resources (CPU, memory and IO).

### Versioning

TwoCaptcha gem uses [Semantic Versioning](http://semver.org/).

### Contributing

1. Fork it ( https://github.com/infosimples/two_captcha/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. **Run/add tests (RSpec)**
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
7. Yay. Thanks for contributing :)

All contributors:
https://github.com/infosimples/two_captcha/graphs/contributors


# License

MIT License. Copyright (C) 2011-2022 Infosimples. https://infosimples.com/

Developed by [Infosimples](https://infosimples.com), a [big data company](https://infosimples.com/en/data-engineering).

# TwoCaptcha

TwoCaptcha is a Ruby API for 2Captcha - [2Captcha.com](http://2captcha.com/?from=1025109).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'two_captcha'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install two_captcha

## Usage

1. **Create a client**

  ```ruby
  # Create a client
  client = TwoCaptcha.new('my_captcha_key')
  ```

2. **Solve a captcha**

  There are two methods available: **decode** and **decode!**
    * **decode** doesn't raise exceptions.
    * **decode!** may raise a *TwoCaptcha::Error* if something goes wrong.

  If the solution is not available, an empty captcha object will be returned.

  ```ruby
  captcha = client.decode!(url: 'http://bit.ly/1xXZcKo')
  captcha.text        # Solution of the captcha
  captcha.id          # Numeric ID of the captcha solved by TwoCaptcha
  ```

  You can also specify *path*, *file*, *raw* and *raw64* when decoding an image.

  ```ruby
  client.decode(path: 'path/to/my/captcha/file')

  client.decode(file: File.open('path/to/my/captcha/file', 'rb'))

  client.decode(raw: File.open('path/to/my/captcha/file', 'rb').read)

  client.decode(raw64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
  ```

  > Internally, the gem will always convert the image to raw64 (binary base64 encoded).

  You may also specify any POST parameters specified at
  https://2captcha.com/setting.

3. **Retrieve a previously solved captcha**

  ```ruby
  captcha = client.captcha('130920620') # with 130920620 as the captcha id
  ```

4. **Report incorrectly solved captcha for refund**

  ```ruby
  client.report!('130920620') # with 130920620 as the captcha id
  # return true if successfully reported
  ```

  > ***Warning:*** *do not abuse on this method, otherwise you may get banned*

5. **Get your balance on 2Captcha**

  ```ruby
  client.balance
  # return a Float balance in USD.
  ```

6. **Get usage statistics for a specific date**

  ```ruby
  client.stats('2015-08-05')
  # return an XML string with your usage statistics.
  ```

7. **Get current 2Captcha load**

  ```ruby
  client.load
  # return an XML string with the current service load.
  ```

## Clickable CAPTCHAs (e.g. "No CAPTCHA reCAPTCHA")

There are two ways of solving captchas similar to
[reCAPTCHA v2](https://support.google.com/recaptcha/?hl=en#6262736).

### (Prefered) Sending the `googlekey` and `pageurl` parameters

This method requires no browser emulation. You can send two parameters that identify website in which the captcha is found.

Please read the oficial documentation at https://2captcha.com/newapi-recaptcha-en for
more information.

  ```ruby
  options = {
    googlekey: 'xyz',
    pageurl: 'http://example.com/example=1'
  }

  client.decode_recaptcha_v2(options)
  ```

  The response will be a code that validates the form, like the following:

  ```ruby
  "03AHJ_VuuHAqJKxcTH6sbTsqw-L1Sm4gD57PTeaEr9-MaETG1vfu2H5zlcw0u2KqgjHPiXWwlulOw0Ef82tH6SOSbXdelgkvdDl8HreKFug05zfadw2n-A2HoTgYteVA53Q46VatEcZofa5eKfaWgvrPS-IP1DpV4bnUEG69-VbWAx7fJ-p4rHSxq-ZYesBkk9yYFrAiT_70uSz8lg3iqRImfRW91RIkEq8A5UBn4vABUQvlDV4eoKpeNUKDmHOABHkdsV8_1KEgCbabIwsIuIkN1_hw-Mkg0NRdWuXgNtOWen0Zv65yl6D31yhyLV2s0h3ygQwrpxJpBWs7o_rG2TaVfi0y9S5cYr-YlMTHszvMQCVllf5WAiNAgV28JuAnFH5WqRHqT56Tz6ZVNigIToEzq1tnfuewgmJuyyP_woy_MGRoZoHxx6V9yUDw8Ig-hYD8kakmSnnjNQd50w_Y_tI3aDLp-s_7ZmhH6pcaoWWsid5hdtMXyvrP9DscDuCLBf7etLle8caPWSaYCpAq9DOTtj5NpSg6-OeCJdGdgIPT9Xdbo_dm4pLGZ0CNd5WQcjil_kZN_uErRssv9r8j5SC6tsIPBneQLqqqsg8Hyt9kjIh0N10d6-sFeV3QWw-OuzCrPSNYc-_AxvwaB0GUAOmHDDbj8kKz1oqfdBwJienRm246cbstqdc7uAHHuLWLpt1A5W-56PEbb3Zs-HNo3kcjvlJcfrOVJKW68-G3S635EJ9SBm9GFKzFojEu4-TF9CvYNJKaXY9dDev_TVbBaWpWN2Ctx5hHKRbtD1_g2LsGUTDkpo7wrf4pbAyP34zeMRBI1wrrV12PBKnuafaMjy2KIFLt0LM91uWiBzEC61AiSKKEwP2nydRIyIFGwbLFUMeGeqmje87wSajcjmdjl_w4XZBY2zy8fUH6XoAGZ6AeCTulIljBQDObQynKDd-rutPvKNxZw3sra3yRt9ziDVKKDk-LbhTfw508g1lu9io6jnvm3kbAdnkfZ0x0PkGiUMHU7hnuoW6bXo2Yn_Zt5tDWL7N7wFtY6B0k7cTy73f8er508zReOuoyz2NqL8smDCmcJu05kr5R6OVHfeUszn5OiYeVh8Q_gTMsEf4wdaOsQWGZhWQIS8Vi_6IYzwQsnOtYdI6T8q4IDrQh-9eemVn0gNI6gdyknStQ7DoujdPGt20qzpURMwHaw"
  ```

### Sending the challenge image

You can add the param `coordinatescaptcha: 1` to your request.

Please read the oficial documentation at https://2captcha.com/en-api-recaptcha for
more information.

  ```ruby
  client.decode(url: 'http://bit.ly/clickcaptcha', coordinatescaptcha: 1)
  ```

**Captcha (screenshot)**

> the argument is passed as *url*, *path*, *file*, *raw* or *raw64*

![Example of a captcha based on image clicks](captchas/2.jpg)

The response will be an array containing coordinates where the captcha should be
clicked. For the captcha above it should look something like:

  ```ruby
  # captcha.text
  "coordinates:x=50.66999816894531,y=130.3300018310547;x=236.66998291015625,y=328.3299865722656"
  ```

## Audio reCAPTCHA v2

  ```ruby
  client.decode(url: 'http://bit.ly/audiorecaptchav2', recaptchavoice: 1)
  ```

The response will be a simple text:

```ruby
# captcha.text
'61267'
```

## Notes

#### Thread-safety

The API is thread-safe, which means it is perfectly fine to share a client
instance between multiple threads.

#### Ruby dependencies

TwoCaptcha don't require specific dependencies. That saves you memory and
avoid conflicts with other gems.

#### Input image format

Any format you use in the decode method (url, file, path, raw, raw64) will
always be converted to a raw64, which is a binary base64 encoded string. So, if
you already have this format available on your side, there's no need to do
convertions before calling the API.

> Our recomendation is to never convert your image format, unless needed. Let
> the gem convert internally. It may save you resources (CPU, memory and IO).

#### Versioning

TwoCaptcha gem uses [Semantic Versioning](http://semver.org/).

#### Tested Ruby versions

* MRI 2.2.2
* MRI 2.2.0
* MRI 2.1.4
* MRI 2.0.0

## Contributing

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

MIT License. Copyright (C) 2011-2015 Infosimples. https://infosimples.com/

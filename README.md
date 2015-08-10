Developed by [Infosimples](https://infosimples.com), a brazilian company that
offers [data extraction solutions](https://infosimples.com/en/data-engineering)
and [Ruby on Rails development](https://infosimples.com/en/software-development).

# TwoCaptcha

TwoCaptcha is a Ruby API for 2Captcha - https://2captcha.com.

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
  #
  client = TwoCaptcha.new('mykey')
  ```

  This will create a client with default parameters. The available params are:

  ```ruby
  {
    timeout:  60, # Time in seconds to try and get a solution
    pooling:  5,  # Time in seconds between two requests on the same captcha_id
    phrase:   0,  # Specifies if captcha has 2 words (1) or not (0)
    regsense: 0,  # Specifies if captcha is case sensetive (1) or not (0)
    numeric:  0,  # Specifies type of captcha (0: not specified, 1: numeric, 2: letters, 3: aphanumeric)
    calc:     0,  # Specifies math Captcha (1) or not specified (0)
    min_len:  0,  # Specifies minimum length (1..20) or not specified (0)
    max_len:  0   # Specifies maximum length (1..20) or not specified (0)
  }
  ```

  If not specified the params are not passed for 2Captcha API and it will use API default
  as the hash above.

2. **Solve a captcha**

  There are two methods available: **decode** and **decode!**
    * **decode** doesn't raise exceptions.
    * **decode!** may raise a *TwoCaptcha::Error* if something goes wrong.

  If the solution is not available, a captcha object will be returned with status 'ERROR' and
  message with the error.

  ```ruby
  captcha = client.decode(url: 'http://bit.ly/1xXZcKo')
  captcha.status      # Status: 'OK' or 'ERROR'
  captcha.text        # Solution of the captcha, in case of success
  captcha.id          # Numeric ID of the captcha solved by TwoCaptcha
  captcha.message     # Error message, in case of error
  ```

  You can also specify *path*, *file*, *raw* and *raw64* when decoding an image.

  ```ruby
  client.decode(path: 'path/to/my/captcha/file')

  client.decode(file: File.open('path/to/my/captcha/file', 'rb'))

  client.decode(raw: File.open('path/to/my/captcha/file', 'rb').read)

  client.decode(raw64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
  ```

  For new reCAPTCHA, add the 'id_constructor = 23' param:

  ```ruby
  client.decode(url: 'http://bit.ly/1xXZcKo', id_constructor: 23)
  ```

  > Internally, the gem will always convert the image to raw64 (binary base64 encoded).

3. **Retrieve a previously solved captcha**

  ```ruby
  captcha = client.captcha_result('130920620') # with 130920620 as the captcha id
  ```

3. **Upload a captcha without get the solution**

  ```ruby
  captcha = client.upload_captcha(url: 'http://bit.ly/1xXZcKo')
  captcha.status  # 'OK' or 'ERROR'
  captcha.message # In case of success: captcha id, otherwise: error message
  ```

5. **Report incorrectly solved captcha for refund**

  ```ruby
  captcha = client.report_incorrect('130920620') # with 130920620 as the captcha id
  captcha.status      # Status: 'OK' or 'ERROR'
  captcha.id          # Numeric ID of the captcha solved by 2Captcha
  captcha.message     # TwoCaptcha::NotReported error message, in case of error
                      # and success message otherwise
  ```

  > ***Warning:*** *do not abuse on this method, otherwise you may get banned*

6. **Get your balance on 2Captcha**

  ```ruby
  balance = client.balance
  ```

7. **Get statistics from a date**

  ```ruby
  stats = client.statistics(2015-08-05)
  stats # XML string with your stats on the date
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
> the gem convert internally. It may save you resources (CPU, memmory and IO).

#### Versioning

TwoCaptcha gem uses [Semantic Versioning](http://semver.org/).

#### Ruby versions tested

* MRI 2.2.2
* MRI 2.2.0
* MRI 2.1.4
* MRI 2.0.0

# Maintainers

* [Marcelo Mita](http://github.com/marcelomita)

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

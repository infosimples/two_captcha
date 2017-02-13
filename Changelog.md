# TwoCaptcha Changes

### 1.4.0

* **breaking changes:**
  * The method "decode_recaptcha_v2" now always return a TwoCaptcha::Captcha
    object. It was returning a string when successful.
* enhancements:
  * Add tests to solve RecaptchaV2 with the preferred method.

require 'spec_helper'

token            = CREDENTIALS['token']
captcha_url      = CREDENTIALS['captcha_url']
captcha_id       = CREDENTIALS['captcha_id']
captcha_solution = CREDENTIALS['solution']
image64          = Base64.encode64(File.open('captchas/1.png', 'rb').read)

describe TwoCaptcha::Client do
  describe 'create' do
    context 'default' do
      let(:client) { TwoCaptcha.new(token) }
      it { expect(client).to be_a(TwoCaptcha::Client) }
      it { expect(client.timeout).to eq(60) }
      it { expect(client.pooling).to eq(5) }
    end

    context 'timeout = 30 seconds' do
      let(:timeout_client) { TwoCaptcha.new(token, timeout: 30) }
      it { expect(timeout_client).to be_a(TwoCaptcha::Client) }
      it { expect(timeout_client.timeout).to eq(30) }
      it { expect(timeout_client.pooling).to eq(5) }
    end

    context 'pooling = 3 seconds' do
      let(:pooling_client) { TwoCaptcha.new(token, pooling: 3) }
      it { expect(pooling_client).to be_a(TwoCaptcha::Client) }
      it { expect(pooling_client.timeout).to eq(60) }
      it { expect(pooling_client.pooling).to eq(3) }
    end
  end
  context 'methods' do
    before(:all) { @client = TwoCaptcha.new(token) }

    describe '#load_captcha' do
      it { expect(@client.send(:load_captcha, url: 'http://bit.ly/1xXZcKo')).to eq(image64) }
      it { expect(@client.send(:load_captcha, path: 'captchas/1.png')).to eq(image64) }
      it { expect(@client.send(:load_captcha, file: File.open('captchas/1.png', 'rb'))).to eq(image64) }
      it { expect(@client.send(:load_captcha, raw: File.open('captchas/1.png', 'rb').read)).to eq(image64) }
      it { expect(@client.send(:load_captcha, raw64: image64)).to eq(image64) }
    end

    describe '#upload_captcha' do
      before(:all) { @upload = @client.upload_captcha(url: captcha_url) }
      it { expect(@upload[:status]).to eq('OK') }
      it { expect(@upload[:message]).to match(/[0-9]{9}/) }
    end

    describe '#captcha_result' do
      before(:all) { @captcha = @client.captcha_result(captcha_id) }
      it { expect(@captcha).to be_a(TwoCaptcha::Captcha) }
      it { expect(@captcha.status).to eq('OK') }
      it { expect(@captcha.text).to eq(captcha_solution) }
      it { expect(@captcha.id).to eq(captcha_id) }
    end

    describe '#decode!' do
      before(:all) { @captcha = @client.decode!(raw64: image64) }
      it { expect(@captcha).to be_a(TwoCaptcha::Captcha) }
      it { expect(@captcha.text.downcase).to eq 'infosimples' }
      it { expect(@captcha.id).to match(/[0-9]{9}/) }
    end

    describe '#balance' do
      before(:all) { @balance = @client.balance }
      it { expect(@balance).to be > 0 }
    end
  end
end

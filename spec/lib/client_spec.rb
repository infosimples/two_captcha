require 'spec_helper'

key              = CREDENTIALS['key']
captcha_id       = CREDENTIALS['captcha_id']
captcha_solution = CREDENTIALS['solution']
image64          = Base64.encode64(File.open('captchas/1.png', 'rb').read)
clickable64      = Base64.encode64(File.open('captchas/2.jpg', 'rb').read)

describe TwoCaptcha::Client do
  describe 'create' do
    context 'default' do
      let(:client) { TwoCaptcha.new(key) }
      it { expect(client).to be_a(TwoCaptcha::Client) }
      it { expect(client.timeout).to be > 0 }
      it { expect(client.polling).to be > 0 }
    end

    context 'timeout = 30 seconds' do
      let(:timeout_client) { TwoCaptcha.new(key, timeout: 30) }
      it { expect(timeout_client).to be_a(TwoCaptcha::Client) }
      it { expect(timeout_client.timeout).to eq(30) }
    end

    context 'polling = 3 seconds' do
      let(:polling_client) { TwoCaptcha.new(key, polling: 3) }
      it { expect(polling_client).to be_a(TwoCaptcha::Client) }
      it { expect(polling_client.polling).to eq(3) }
    end
  end
  context 'methods' do
    before(:all) { @client = TwoCaptcha.new(key) }

    describe '#load_captcha' do
      it { expect(@client.send(:load_captcha, url: 'http://bit.ly/1xXZcKo')).to eq(image64) }
      it { expect(@client.send(:load_captcha, path: 'captchas/1.png')).to eq(image64) }
      it { expect(@client.send(:load_captcha, file: File.open('captchas/1.png', 'rb'))).to eq(image64) }
      it { expect(@client.send(:load_captcha, raw: File.open('captchas/1.png', 'rb').read)).to eq(image64) }
      it { expect(@client.send(:load_captcha, raw64: image64)).to eq(image64) }
    end

    describe '#captcha' do
      before(:all) { @captcha = @client.captcha(captcha_id) }
      it { expect(@captcha).to be_a(TwoCaptcha::Captcha) }
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

  context 'clickable CAPTCHA' do
    before(:all) { @client = TwoCaptcha.new(key) }

    describe '#decode!' do
      before(:all) do
        @captcha = @client.decode!(raw64: clickable64, coordinatescaptcha: 1)
        @xy1, @xy2 = @captcha.coordinates.sort_by { |e| e[0] }
      end

      it { expect(@captcha).to be_a(TwoCaptcha::Captcha) }
      it { expect(@captcha.id).to match(/[0-9]{9}/) }

      it { expect(@captcha.coordinates.size).to eq(2) }
      it { expect(@xy1[0]).to be_between(9, 99).inclusive }
      it { expect(@xy1[1]).to be_between(97, 187).inclusive }
      it { expect(@xy2[0]).to be_between(187, 279).inclusive }
      it { expect(@xy2[1]).to be_between(276, 366).inclusive }
    end
  end
end

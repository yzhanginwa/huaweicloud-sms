require 'securerandom'
require 'digest'
require 'base64'
require 'net/http'
require 'uri'
require 'active_support/all'

module HuaweicloudSms
  class Base
    def initialize(app_key, app_secret, url)
      @app_key = app_key
      @app_secret = app_secret
      @url = url
    end

    def send(sender, receiver, template_id, template_params, signature)
      url = URI.parse(@url)
      request = Net::HTTP::Post.new(url.path)

      # template_param needs to be an array of strings
      template_param = '[' + template_params.map{ |p| "\"#{p}\"" }.join(',') +  ']'

      form_data = { 'from'           => sender,
                    'to'             => receiver,
                    'templateId'     => template_id,
                    'templateParas'  => template_param,
                    'statusCallback' => '',
                    'signature'      => signature
      }

      request.set_form_data(form_data)

      request['Authorization'] = 'WSSE realm="SDP",profile="UsernameToken",type="Appkey"'
      request['X-WSSE'] = build_wss_header(@app_key, @app_secret)

      response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
        http.request(request)
      end

      { code: response.code, body: response.body }
    end

    private

    def build_wss_header(app_key, app_secret)
      now = Time.now.utc.iso8601
      nonce = SecureRandom.uuid.gsub('-', '')
      digest = Digest::SHA256.hexdigest(nonce + now + app_secret)
      digest_base64 = Base64.strict_encode64(digest)
      "UsernameToken Username=\"#{app_key}\",PasswordDigest=\"#{digest_base64}\",Nonce=\"#{nonce}\",Created=\"#{now}\""
    end
  end
end

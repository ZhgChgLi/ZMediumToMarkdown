$lib = File.expand_path('../lib', File.dirname(__FILE__))

require 'net/http'
require 'nokogiri'

class Request
    def self.URL(url, method = 'GET', data = nil, retryCount = 0)
        retryCount += 1
        
        uri = URI(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        # --- TLS / Certificate verification setup ---
        # Some OpenSSL builds/configs enable CRL checking, which can fail with:
        # "certificate verify failed (unable to get certificate CRL)".
        # Net::HTTP/OpenSSL does not automatically fetch CRLs, so we use a default
        # cert store and clear CRL-related flags to avoid hard failures while still
        # verifying the peer certificate.
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER

        store = OpenSSL::X509::Store.new
        store.set_default_paths
        # Ensure no CRL-check flags are enabled by default
        store.flags = 0
        https.cert_store = store

        # Allow overriding CA bundle paths via environment variables if needed.
        if ENV['SSL_CERT_FILE'] && !ENV['SSL_CERT_FILE'].empty?
          https.ca_file = ENV['SSL_CERT_FILE']
        end
        if ENV['SSL_CERT_DIR'] && !ENV['SSL_CERT_DIR'].empty?
          https.ca_path = ENV['SSL_CERT_DIR']
        end

        # (Optional) timeouts to avoid hanging on network issues
        https.open_timeout = 10
        https.read_timeout = 30
        # --- end TLS setup ---

        if method.upcase == "GET"
            request = Net::HTTP::Get.new(uri)
            request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0';
        else
            request = Net::HTTP::Post.new(uri)
            request['Content-Type'] = 'application/json'
            if !data.nil?
                request.body = JSON.dump(data)
            end
        end

        cookiesString = $cookies.reject { |_, value| value.nil? }
        .map { |key, value| "#{key}=#{value}" }
        .join("; ");

        if !cookiesString.nil? && cookiesString != ""
          request['Cookie'] = cookiesString;
        end

        response = https.request(request);
          
        setCookieString = response.get_fields('set-cookie');
        if !setCookieString.nil? && setCookieString != ""
          setCookies = setCookieString.map { |cookie| cookie.split('; ').first }.each_with_object({}) do |cookie, hash|
            key, value = cookie.split('=', 2) # Split by '=' into key and value
            hash[key] = value
          end;

          setCookies.each do |key, value|
            $cookies[key] = value
          end
        end

        # 3XX Redirect
        if response.code.to_i == 429
          if retryCount >= 10
            raise "Error: Too Manay Reqeust, blocked by Medium. URL: #{url}";
          else
            response = self.URL(url, method, data, retryCount);
          end
        elsif response.code.to_i >= 300 && response.code.to_i <= 399 && !response['location'].nil? && response['location'] != ''
            if retryCount >= 10
                raise "Error: Retry limit reached. URL: #{url}"
            else
                location = response['location']
                if !location.match? /^(http)/
                    location = "#{uri.scheme}://#{uri.host}#{location}"
                end
                
                response = self.URL(location, method, data, retryCount)
            end
        end

        puts response.read_body
        
        response
    end

    def self.html(response)
      if response.nil? || (response && response.code.to_i != 200)
        nil
      else
        Nokogiri::HTML(response.read_body)
      end
    end

    def self.body(response)
      if response.nil? || (response && response.code.to_i != 200)
        nil
      else
        response.read_body
      end
    end
end

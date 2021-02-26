# frozen_string_literal: true

module WebmockHelper
  def self.response_body(path)
    pathname = File.join(%w[spec webmocks purple_air_api], path)
    File.read(pathname)
  end
end

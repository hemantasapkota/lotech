return [=[
module Authlogic
  module Random
    extend self

    SecureRandom = (defined?(::SecureRandom) && ::SecureRandom) ||
    (defined?(::ActiveSupport::SecureRandom) && ::ActiveSupport::SecureRandom)

    if SecureRandom
      def hex_token
        SecureRandom.hex(64)
      end

      def friendly_token
        SecureRandom.base64(15).tr('+/=', '').strip.delete(" ")
      end
    else
      def hex_token
        Authlogic::CryptoProviders::Sha512.encrypt(Time.now.to_s +
        (1..10).collect{ rand.to_s }.join)
      end

      FRIENDLY_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

      def friendly_token
        newpass = ''
        1.upto(20) { |i| newpass << FRIENDLY_CHARS[rand(FRIENDLY_CHARS.size-1)] }
        newpass
      end
    end
  end
end
]=]

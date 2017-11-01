require 'prime'

def large_primes
  @large_primes ||= Prime.take(1_000_000).last(10_000)
end

class String
  def to_number
    number = 0
    each_byte { |byte| number = number * 256 + byte }
    number
  end
end

class RSA
  Key = Struct.new(:modulus, :exponent)

  attr_reader :public_key, :private_key

  def initialize
    generate_keys
  end

  def encrypt(message)
    number = s_to_n(message)
    mod_pow(number, public_key.exponent, public_key.modulus)
  end

  def decrypt(cypher)
    number = mod_pow(cypher.to_i, private_key.exponent, private_key.modulus)
    n_to_s(number)
  end

  private

  # https://en.wikipedia.org/wiki/Modular_exponentiation
  def mod_pow(base, power, mod)
    res = 1
    while power > 0
      res = (res * base) % mod if power & 1 == 1
      base = base ** 2 % mod
      power >>= 1
    end
    res
  end

  # Convert number to string
    def n_to_s( n )
      s = ""
      while( n > 0 )
        s = ( n & 0xFF ).chr + s
        n >>= 8
      end
      s
    end

    # Convert string to number
    def s_to_n( s )
      n = 0
      s.each_byte do |b| 
        n = n * 256 + b 
      end
      n
    end

  def totient(p, q)
    (p - 1) * (q - 1)
  end

  # Extended euclidean
  def egcd(a, b)
    return [0, 1] if a % b == 0
    x, y = egcd(b, a % b)
    [y, x - y * (a / b)]
  end

  def generate_keys
    p, q = large_primes.sample(2)
    n = p * q

    totient = totient(p, q)

    # e = (2...totient).lazy
    #   .select { |e| e.gcd(totient) == 1 }
    #   .take(10_000).to_a.sample
    e = 65537

    d = modular_inverse(e, totient)

    @public_key = Key.new(n, e)
    @private_key = Key.new(n, d)
  end

  def modular_inverse(e, totient)
    x, y = egcd(e, totient)
    x += totient if x < 0
    x
  end
end

rsa = RSA.new
cypher = rsa.encrypt 'hi there'

puts rsa.decrypt(cypher)


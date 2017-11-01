module RSA
  module_function

  # Euler totient
  def totient(a, b)
    (a - 1) * (b - 1)
  end

  # https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
  def egcd(a, b)
    return [0,1] if a % b == 0
    x, y = egcd(b, a % b)
    [y, x - y * (a / b)]
  end

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

  # pulic exponent, apparently a very common one.
  E = 65537

  def generate_keys(bits)
    p = large_prime(bits)
    q = large_prime(bits)
    n = p * q
    d = mod_inv(p, q, E)
    [n, E, d]
  end

  def encrypt(m, n)
    m = as_number(m)
    mod_pow(m, E, n)
  end

  def decrypt(c, n, d)
    m = mod_pow(c, d, n)
    as_string(m)
  end

  def as_string(number)
    s = ""
    while (number > 0)
      s = (number & 0xFF).chr + s
      number >>= 8
    end
    s
  end

  def as_number(string)
    n = 0
    string.each_byte { |b| n = n * 256 + b }
    n
  end

  # Random bignum of bits size
  def rand_bignum(bits)
    m = (1..bits - 2).map{ rand() > 0.5 ? '1' : '0' }.join
    s = "1#{m}1"
    s.to_i(2)
  end

  # Super slow version to generate large primes with size bits.
  def large_prime(bits)
    while true
      n = rand_bignum bits
      return n if prime?(n)
    end
  end

  # https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
  def mod_inv(p, q, e)
    t = totient(p, q)
    x, y = egcd(e, t)
    x += t if x < 0
    x
  end

  # Common more or less fast method to check prime
  def prime?(n)
    n = n.abs
    return true if n == 2
    return false if n == 1 || n & 1 == 0
    return false if n > 3 && n % 6 != 1 && n % 6 != 5

    d = n-1
    d >>= 1 while d & 1 == 0
    20.times do
      a = rand(n-2) + 1
      t = d
      y = mod_pow(a, t, n)
      while t != n-1 && y != 1 && y != n-1
        y = (y * y) % n
        t <<= 1
      end
      return false if y != n-1 && t & 1 == 0
    end
    return true
  end
end

class SlugGenerator
  def initialize length=6
    @length = length
  end

  def to_s
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
    string = (0...@length).map { o[rand(o.length)] }.join
  end
end
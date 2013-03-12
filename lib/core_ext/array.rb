class Array
  def each_with_fl
    each_with_index do |x,i|
      yield [x, i==0 ? 'first' : (i==length-1 ? 'last' : '')]
    end
  end

  def each_with_css modulo, last=nil, first=nil
    each_with_index do |x,i|
      j = i+1
      if j % modulo == 0
        yield x, last
      elsif first and (j+modulo-1) % modulo == 0
        yield x, first
      else
        yield x, ''
      end
    end
  end
end
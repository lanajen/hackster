class Mouser::BaseController < ActionController::Base
layout 'mouser'
helper_method :title
helper_method :meta_desc

private
  def meta_desc meta_desc=nil
    if meta_desc
      @meta_desc = meta_desc
    elsif @meta_desc
      @meta_desc
    else
      @meta_desc = 'Mouser Summer Contest'
    end
  end

  def title title=nil
    if title
      @title = title
    elsif @title
      @title
    else
      @title = 'Mouser Summer Contest'
    end
  end

  def redis
    @redis ||= Redis::Namespace.new('mouser', redis: RedisConn.conn)
  end
end
class LandingPagesController < ActionController::Base
  layout 'blank'
  helper_method :title
  helper_method :meta_desc

  def intel
    set_surrogate_key_header 'intel_landing'
    set_cache_control_headers 86400

    title "US Maker Competition - Intel"
    meta_desc "US Maker Competition - Intel"
  end

  def survey
    title "Maker Survey 2016"
    meta_desc "Maker Survey 2016"
  end

  private
    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      elsif @meta_desc
        @meta_desc
      else
        @meta_desc = 'Hackster.io'
      end
    end

    def title title=nil
      if title
        @title = title
      elsif @title
        @title
      else
        @title = 'Hackster.io'
      end
    end
end
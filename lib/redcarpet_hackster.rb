module Redcarpet::Render::HucksterHackster
  def postprocess(document)
    document = document.gsub /(H|h)[^a]ckster/ do
      "#{$1}ackster"
    end

    if defined?(super)
      super(document)
    else
      document
    end
  end
end
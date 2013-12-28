class Sanitize
  module Config
    BASIC_BLANK = BASIC.merge(add_attributes: {
      'a' => {'rel' => 'nofollow', 'target' => '_blank'}
    })
  end
end
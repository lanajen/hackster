class Sanitize
  module Config
    BASIC_BLANK = BASIC.merge(add_attributes: {
      'a' => {'rel' => 'nofollow', 'target' => '_blank'}
    })

    PAYPAL_FORM = {
      elements: %w[
        form input table tr td select option img
      ],
      attributes: {
        'form' => %w(method target action),
        'input' => %w(type name value src border alt),
        'select' => %w(name),
        'option' => %w(value),
        'img' => %w(src border alt width height),
      },
      protocols: {
        'img' => {'src' => ['https']},
        'input' => {'src' => ['https']},
        'form' => {'action' => ['https']},
      },
      add_attributes: {
        'form' => {'id' => 'paypal-form'},
      },
    }
  end
end
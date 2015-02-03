class Sanitize
  module Config
    SCRAPER = {
      add_attributes: {
        'a' => {'rel' => 'nofollow', 'target' => '_blank'}
      },
      elements: %w(a br p i b ul ol li pre code div h2 h3 h4 h5 h6 blockquote),
      remove_contents: %w(script style),
      attributes: BASIC[:attributes].merge(
        'div' => %w(class data-url data-caption data-type data-file-id data-widget-id data-video-id)),
      protocols: BASIC[:protocols],
    }

    HACKSTER = {
      add_attributes: {
        'a' => {'rel' => 'nofollow', 'target' => '_blank'}
      },
      elements: %w(a br p i b ul ol li pre code div h2 h3 h4 h5 h6 blockquote),
      remove_contents: %w(script style),
      attributes: BASIC[:attributes],
      protocols: BASIC[:protocols],
    }

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
        'form' => {'target' => '_blank'},
      }
    }
  end
end
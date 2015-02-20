$(function(){
  $('.thumbs-carousel').each(function(i, el) {
    var slideCount = $(el).data('slides-count') || 3;
    $(el).slick({
      infinite: true,
      slidesToShow: slideCount,
      slidesToScroll: slideCount,
      prevArrow: '<button class="carousel-left"><i class="fa fa-chevron-left"></i></button>',
      nextArrow: '<button class="carousel-right"><i class="fa fa-chevron-right"></i></button>',
      responsive: [
        {
          breakpoint: 992,
          settings: 'unslick'
        }
      ]
    })
  });

  // http://jsfiddle.net/Webveloper/HjFUK/
  $.fn.shake = function (options) {
    // defaults
    var settings = {
        'shakes': 2,
        'distance': 10,
        'duration': 400
    };
    // merge options
    if (options) {
        $.extend(settings, options);
    }
    // make it so
    var pos;
    return this.each(function () {
        $this = $(this);
        // position if necessary
        pos = $this.css('position');
        if (!pos || pos === 'static') {
            $this.css('position', 'relative');
        }
        // shake it
        for (var x = 1; x <= settings.shakes; x++) {
            $this.animate({ left: settings.distance * -1 }, (settings.duration / settings.shakes) / 4)
                .animate({ left: settings.distance }, (settings.duration / settings.shakes) / 2)
                .animate({ left: 0 }, (settings.duration / settings.shakes) / 4);
        }
    });
  };

  if (typeof(tagsPrefetch) != 'undefined') {
    $.getScript('//cdnjs.cloudflare.com/ajax/libs/typeahead.js/0.10.4/typeahead.bundle.min.js', function()
    {
      var engine = new Bloodhound({
        datumTokenizer: function(d) {
          return Bloodhound.tokenizers.whitespace(d.tag);
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        local: tagsPrefetch
      });

      // kicks off the loading/processing of `local` and `prefetch`
      engine.initialize();

      // platforms
      // lists
      // tags

      $('.typeahead').typeahead({
        hint: true,
        highlight: false,
        minLength: 1
      },
      {
        name: 'tags',
        displayKey: 'tag',
        source: engine.ttAdapter(),
        templates: {
          suggestion: function (data) {
            return "<p><span class='tt-result'>" + data.tag + "</span><span class='tt-context'><strong>" + data.projects + "</strong> projects</span></p>";
          }
        }
      }).on('typeahead:selected', function (obj, datum) {
        window.location = datum.url;
      });;

      $('#hack_select').on('change', function(e){
        window.location = $(this).val();
      });
      $('.scrolldown').on('click', function(e){
        e.preventDefault();
        var id = $('#home-banner').next().attr('id');
        smoothScrollTo('#' + id);
      });
      $('#typeahead-label').on('click', function(e){
        $(this).animate({ opacity: 0 }, 200, function(){
          $(this).hide();
          $('#typeahead').animate({ opacity: 1 }, 100).focus();
        });
      });
      $('#typeahead')
        .on('focusout', function(e){
          $(this).animate({ opacity: 0 }, 100, function(){
            $('#typeahead-label').show().animate({ opacity: 1 }, 200);
            $(this).typeahead('val', '');
          });
        })
        .on('keypress', function(e){
          if (e.which == 13 && !e.shiftKey) {
            e.preventDefault();
            engine.get($(this).val(), function(suggestions) {
              var match;
              $.each(suggestions, function(i, suggestion) {
                match = suggestion;
                return window.location = suggestion.url;
              });
              if (match == null) $('.shakable').shake();
            });
          }
        });
    });
  }

  if ($('#infinite-scrolling').size() > 0) {
    $(window).on('scroll', function(){
      var more_posts_url = $('.pagination .next_page a').attr('href');
      if (more_posts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 1000) {
        $('#loader').html('<i class="fa fa-spin fa-spinner"></i>');
        $.getScript(more_posts_url);
      }
    });
  }
});
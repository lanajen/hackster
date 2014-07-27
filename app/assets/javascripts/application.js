//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap_custom
//= require jquery_nested_form
// require wysihtml5
//= require parser_rules/advanced
//= require placeholders
//= require jquery.parallax
//= require jquery.ui.sortable
//= require jquery.throttle
//= require slick.min
// require 'wysihtml5/parser_rules'
//= require rangy-core
//= require rangy-cssclassapplier
//= require medium-editor
//= require medium-editor-ext

//= require projects
//= require groups
//= require comments
//= require all
//= require mobile
//= require ilightbox/jquery.mousewheel
//= require ilightbox/ilightbox.packed
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload


(function($) {

  var oldHide = $.fn.popover.Constructor.prototype.hide;

  $.fn.popover.Constructor.prototype.hide = function() {
    if (this.options.trigger === "hover" && this.tip().is(":hover")) {
      var that = this;
      // try again after what would have been the delay
      setTimeout(function() {
          return that.hide.call(that, arguments);
      }, that.options.delay.hide);
      return;
    }
    oldHide.call(this, arguments);
  };

})(jQuery);
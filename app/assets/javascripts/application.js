//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap_custom
//= require jquery_nested_form
//= require wysihtml5
//= require parser_rules/advanced
//= require placeholders
//= require jquery.ui.sortable
//= require jquery.throttle

//= require projects
//= require groups
//= require comments
//= require all
//= require ilightbox/jquery.mousewheel
//= require ilightbox/ilightbox.packed
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload

// require jquery.fileupload-process
// require jquery.fileupload-validate
// require js-routes
// require underscore
// require hamlcoffee
// require backbone
// require backbone.marionette
// require lib/underscore
// require lib/backbone
// require lib/marionette
// require_tree ./backbone/config
// require backbone/app
// require_tree ./backbone/entities
// require_tree ./backbone/views
// require_tree ./backbone/apps

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
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap_custom
//= require underscore
//= require jquery-ui/sortable
//= require jquery-ui/widget
//= require jquery.parallax
//= require jquery.throttle
//= require jquery.resize
//= require jquery.githubRepoWidget.min
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require ilightbox/jquery.mousewheel
//= require ilightbox/ilightbox.packed
//= require jquery_nested_form
//= require js-cookie
//= require bitbucket-widget.min
//= require slick
//= require rangy-core
//= require rangy-cssclassapplier
//= require moment
//= require medium-editor
//= require placeholders
//= require medium-editor-ext
//= require gist-embed
//= require chats
//= require projects
//= require groups
//= require comments
//= require modals
//= require all
//= require mobile
//= require home
//= require components

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

hljs.initHighlightingOnLoad();
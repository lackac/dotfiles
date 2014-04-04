
// Disables hijacking Cmd-clicks on links to open pages in a new tab.
// https://gist.github.com/4558999
;(function($) {
  document.addEventListener('click', function(event) {
    if (event.metaKey || event.altKey) {
      var link = $(event.target).closest('a[href]')
      if (link.size()) event.stopPropagation()
    }
  }, true)
})(jQuery)

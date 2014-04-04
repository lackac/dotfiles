;(function($) {

var container = $('<td/>', {
  css: {
    'text-align': 'left',
    'font-size': '14px'
  },
  colspan: 10,
  'class': 'colhead'
});

var filter = $('<input/>', {
  css: {
    border: '1px solid black',
    padding: '2px',
    width: '500px',
    'font-size': '14px'
  },
  id: 'bithumen-filter',
  type: 'text',
  placeholder: 'példák: "7 dráma", "<3 horror", ">6.5 -horror", "dráma romantikus"',
  value: localStorage['bithumen-filter'],
  change: function(e) {
    localStorage['bithumen-filter'] = $(this).val();
    var expr = $(this).val().trim().split(/\s+/),
        compRe = /^(?:<|<=|==|>=|>)/;
    $('#torrenttable tr').each(function(x) {
      if (x < 2) { return; }
      var torrent = $(this).find('td:eq(1)');

      var year = parseInt(torrent.find('a[href^="details.php"]').text().match(/\d\d\d\d/)),
          imdbScore = parseFloat(torrent.find('a[href*="imdb.com"]').text().match(/[\d\.]+/)) || 0,
          genres = $.makeArray(torrent.find('a[href^="browse.php?genre="]').map(function() { return $(this).text(); })),
          match = true;

      $.each(expr, function(i, ex) {
        var m;
        if (!isNaN(m = parseFloat(ex.replace(compRe, '').replace(/^=/, '')))) {
          if (!ex.match(compRe)) {
            ex = (ex.match(/^=/) ? "=" : ">=") + ex;
          }
          if (m > 1900) {
            if (year && !eval(year + ex)) {
              return match = false;
            }
          } else {
            if (!eval(imdbScore + ex)) {
              return match = false;
            }
          }
        } else if (ex) {
          if (ex.match(/^-/)) {
            var exclude = true;
            ex = ex.substr(1);
          }
          var included = genres.indexOf(ex) != -1;
          if (included && exclude || !included && !exclude) {
            return match = false;
          }
        }
      });
      match ? $(this).show() : $(this).hide();
    });
  }
});

container.append($('<label/>', {
  css: {display: 'inline-block', width: '100px'},
  'for': 'bithumen-filter',
  text: "Torrent szűrő"
}));
container.append(filter);

$('#torrenttable').prepend($('<tr/>').append(container));

if (localStorage['bithumen-filter']) {
  filter.change();
}

})(jQuery)

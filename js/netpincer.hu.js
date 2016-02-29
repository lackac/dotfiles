;(function($) {

  var cleanRe  = /\b(?:angolna|surimi|akasaka|subaru|poh|carbonara|prosciutto|pepper[oó]ni|virsli)\b|\b(?:sonk[aá]|bacon|tarj[aá]|sertés|rák|tintahal|tenger gyümölcs|csül[ök])|(?:rák|kagyló|kaviár|szalonna)\b|kolbász|szalámi/i;
  var veggieRe = /\b(?:angolna|surimi|akasaka|subaru|poh|carbonara|prosciutto|pepper[oó]ni|virsli|szardínia|szardella|tonhal)\b|\b(?:sonk[aá]|bacon|tarj[aá]|sertés|rák|tintahal|tenger gyümölcs|csül[ök]|gyros|csirk[eé]|marha|borjú)|(?:rák|kagyló|kaviár|szalonna|hús|hal)\b|kolbász|szalámi/i;

  $('.shop-list-row').filter(function() {
                               return parseInt($('.shop-rate .percent', this).text()) < 90;
                             })
                     .attr('data-is-unpopular', '1');

  $('.item').filter(function() {
                      return !$('.item-text-container', this).text().match(cleanRe);
                    })
            .attr('data-is-clean', '1')
            .closest('.category-content')
            .attr('data-has-clean', '1')
            .prev()
            .attr('data-has-clean', '1');

  $('.item').filter(function() {
                      return !$('.item-text-container', this).text().match(veggieRe);
                    })
            .attr('data-is-veggie', '1')
            .closest('.category-content')
            .attr('data-has-veggie', '1')
            .prev()
            .attr('data-has-veggie', '1');

  function addFilters($) {
    function filterClickHandler(id) {
      return function(e) {
        e.preventDefault();
        e.stopPropagation();
        var li = $(this).parent();
        if (li.hasClass("selected")) {
          $.OrderedFilter._resetCategories();
        } else {
          $.FoodSearch.Search('');
          $(".category.normal").fadeOut(100, function(){
            $.Utils.RemoveClass($("div.filter ul:not(.icon-list) li"), "selected");
            $.Utils.AddClass(li, "selected");
            $.Utils.AddClass($('.filter-personal .filter-clear-icon'), "hide");
            $.Utils.RemoveClass(li.find('.filter-clear-icon'), "hide");
            $.Utils.RemoveClass($("div[data-has-"+id+"='1'].category-header"), "hide");
            $.Utils.RemoveClass($("div[data-has-"+id+"='1'].category-content"), "hide");
            $.Utils.AddClass($("div:not([data-has-"+id+"='1']).category-header"), "hide");
            $.Utils.AddClass($("div:not([data-has-"+id+"='1']).category-content"), "hide");
            $.Utils.AddClass($("div.item:not([data-is-"+id+"='1'])"), "hide");
            $.Utils.RemoveClass($("div.item[data-is-"+id+"='1']"), "hide");
            $(".category.normal").fadeIn(100);
          });
        }
      };
    }

    $('ul.filter-personal').each(function() {
      var cleanLink = $('<a href="#">').text('tiszta').click(filterClickHandler('clean')),
          cleanLi = $('<li>').append(cleanLink),
          veggieLink = $('<a href="#">').text('vegetáriánus').click(filterClickHandler('veggie')),
          veggieLi = $('<li>').append(veggieLink),
          ul = $('<ul class="filter-custom">').append(cleanLi).append(veggieLi);
      $(this).before(ul);
    });

    $('a[data-search-personal]:first').each(function() {
      var link = $('<a href="#">').text('népszerű').click(function(e) {
            e.preventDefault();
            e.stopPropagation();
            if (link.parent().hasClass('selected')) {
              $('.shop-list-content').removeClass('hide-unpopular');
              link.parent().removeClass('selected');
            } else {
              $('.shop-list-content').addClass('hide-unpopular');
              link.parent().addClass('selected');
            }
          }),
          li = $('<li>').append(link);
      $(this).parent().before(li);
    });
  }

  var script = document.createElement('script');
  script.textContent = '(' + addFilters.toString() + ')(jQuery);';
  document.getElementsByTagName('script')[0].parentNode.appendChild(script);

  addGlobalStyle('.shop-list-content.hide-unpopular .shop-list-row[data-is-unpopular] { display: none !important; }');

  function addGlobalStyle(css) {
    var head, style;
    head = document.getElementsByTagName('head')[0];
    if (!head) { return; }
    style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = css;
    head.appendChild(style);
  }

})(jQuery);

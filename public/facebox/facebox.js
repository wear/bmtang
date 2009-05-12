/*
 * Facebox (for jQuery)
 * version: 1.0 (12/19/2007)
 * @requires jQuery v1.2 or later
 *
 * Examples at http://famspam.com/facebox/
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2007 Chris Wanstrath [ chris@ozmm.org ]
 *
 * Usage:
 *  
 *  jQuery(document).ready(function() {
 *    jQuery('a[@rel*=facebox]').facebox() 
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 * 
 *    jQuery.facebox('some html')
 *
 *  This will open a facebox with "some html" as the content.
 *    
 *    jQuery.facebox(function() { ajaxes })
 *
 *  This will show a loading screen before the passed function is called,
 *  allowing for a better ajax experience.
 *
 */
(function($j) {
  $j.facebox = function(data) {
    $j.facebox.init()
    $j.facebox.loading()
    $j.isFunction(data) ? data.call() : $j.facebox.reveal(data)
  }

  $j.facebox.settings = {
    loading_image : '/facebox/loading.gif',
    close_image   : '/facebox/closelabel.gif',
    image_types   : [ 'png', 'jpg', 'jpeg', 'gif' ],
    facebox_html  : '\
  <div id="facebox" style="display:none;"> \
    <div class="popup"> \
      <table> \
        <tbody> \
          <tr> \
            <td class="tl"/><td class="b"/><td class="tr"/> \
          </tr> \
          <tr> \
            <td class="b"/> \
            <td class="body"> \
              <div class="content"> \
              </div> \
              <div class="footer"> \
                <a href="#" class="close"> \
                  <img src="" title="close" class="close_image" /> \
                </a> \
              </div> \
            </td> \
            <td class="b"/> \
          </tr> \
          <tr> \
            <td class="bl"/><td class="b"/><td class="br"/> \
          </tr> \
        </tbody> \
      </table> \
    </div> \
  </div>'
  }

  $j.facebox.loading = function() {
    if ($j('#facebox .loading').length == 1) return true

    $j('#facebox .content').empty()
    $j('#facebox .body').children().hide().end().
      append('<div class="loading"><img src="'+$j.facebox.settings.loading_image+'"/></div>')

    var pageScroll = $j.facebox.getPageScroll()
    $j('#facebox').css({
      top:	pageScroll[1] + ($j.facebox.getPageHeight() / 10),
      left:	pageScroll[0]
    }).show()

    $j(document).bind('keydown.facebox', function(e) {
      if (e.keyCode == 27) $j.facebox.close()
    })
  }

  $j.facebox.reveal = function(data, klass) {
    if (klass) $j('#facebox .content').addClass(klass)
    $j('#facebox .content').append(data)
    $j('#facebox .loading').remove()
    $j('#facebox .body').children().fadeIn('normal')
  }

  $j.facebox.close = function() {
    $j(document).unbind('keydown.facebox')
    $j('#facebox').fadeOut(function() {
      $j('#facebox .content').removeClass().addClass('content')
    })
    return false
  }

  $j.fn.facebox = function() {
    $j.facebox.init()

    var image_types = $j.facebox.settings.image_types.join('|')
    image_types = new RegExp('\.' + image_types + '$j', 'i')

    function click_handler() {
      $j.facebox.loading(true)

      // support for rel="facebox[.inline_popup]" syntax, to add a class
      var klass = this.rel.match(/facebox\[\.(\w+)\]/)
      if (klass) klass = klass[1]

      // div
      if (this.href.match(/#/)) {
        var url    = window.location.href.split('#')[0]
        var target = this.href.replace(url,'')
        $j.facebox.reveal($j(target).clone().show(), klass)

      // image
      } else if (this.href.match(image_types)) {
        var image = new Image()
        image.onload = function() {
          $j.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
        }
        image.src = this.href

      // ajax
      } else {
        $j.get(this.href, function(data) { $j.facebox.reveal(data, klass) })
      }

      return false
    }

    this.click(click_handler)
    return this
  }

  $j.facebox.init = function() {
    if ($j.facebox.settings.inited) {
      return true
    } else {
      $j.facebox.settings.inited = true
    }

    $j('body').append($j.facebox.settings.facebox_html)

    var preload = [ new Image(), new Image() ]
    preload[0].src = $j.facebox.settings.close_image
    preload[1].src = $j.facebox.settings.loading_image

    $j('#facebox').find('.b:first, .bl, .br, .tl, .tr').each(function() {
      preload.push(new Image())
      preload.slice(-1).src = $j(this).css('background-image').replace(/url\((.+)\)/, '$j1')
    })

    $j('#facebox .close').click($j.facebox.close)
    $j('#facebox .close_image').attr('src', $j.facebox.settings.close_image)
  }

  // getPageScroll() by quirksmode.com
  $j.facebox.getPageScroll = function() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;	
    }
    return new Array(xScroll,yScroll) 
  }

  // adapter from getPageSize() by quirksmode.com
  $j.facebox.getPageHeight = function() {
    var windowHeight
    if (self.innerHeight) {	// all except Explorer
      windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      windowHeight = document.body.clientHeight;
    }	
    return windowHeight
  }
})(jQuery);

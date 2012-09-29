// My Functions For Bootstrap
  !function ($) {
  
    $(function(){

      // fix sub nav on scroll( Borrowed Straight From Bootstrap )
      var $win = $(window)
        , $nav = $('.subnav')
      , navHeight = $('.navbar').first().height()
        , navTop = $('.subnav').length && $('.subnav').offset().top - navHeight
        , isFixed = 0
  
      processScroll()
  
      $win.on('scroll', processScroll)
  
      function processScroll() {
        var i, scrollTop = $win.scrollTop()
        if (scrollTop >= navTop && !isFixed) {
          isFixed = 1
          $nav.addClass('subnav-fixed')
        } else if (scrollTop <= navTop && isFixed) {
          isFixed = 0
          $nav.removeClass('subnav-fixed')
        }
      }
  
  })
    
  // make code pretty
    window.prettyPrint && prettyPrint()
    
  // For Popovers  
     // tooltip demo
    $('.tooltip-demo.well').tooltip({
      selector: "a[rel=tooltip]"
    })

    $('.tooltip-test').tooltip()
    $('.menu-pop').popover({
      trigger: 'hover',
      placement: 'top',
      animation: true,
      title: 'Info'
      }
    )
// Use the below function to disable clicking a button with the "rel" attribute in class
     //popover demo
    //$("a[rel=popover]")
    //  .popover()
    //  .click(function(e) {
    //    e.preventDefault()
    //  })


  
  }(window.jQuery)

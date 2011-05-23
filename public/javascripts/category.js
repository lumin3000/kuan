document.addEvent('domready', function(){
  //slides
  K.slide.init()
  K.slide.start()

  //categories
  var el = $$('.categories_box')[0]
  var cat = new Fx.Scroll(el, {
    duration: 500,
    transition:Fx.Transitions.Quad.easeInOut
  })
  $$('.spread_prev').addEvent('click', function(){
    var x = el.getScroll().x
    cat.start(x==0 ? $$('.categories_inner')[0].getWidth()-el.getWidth() : x-600, 0)
  })
  $$('.spread_next').addEvent('click', function(){
    var x = el.getScroll().x
    cat.start(x>$$('.categories_inner')[0].getWidth()-el.getWidth() ? 0 : x+600, 0)
  })
  $$('.categories_inner').setStyle('width', $$('.categories_inner .row').length*100+$$('.categories_inner .row2').length*90)

  //bubbles
  var bubbles = $$('.category_list a')
  var sea
  for(var i=0,l=bubbles.length; i<l; i++){
    if(i%15==0){
      sea = new Element('div', {
        'class': 'spread_tag'+(Number(i/15).floor())%2
      }).inject($$('.category_list')[0], 'before')
    }
    bubbles[i].inject(sea).addClass('bubble'+((i+1)%30==0?30:(i+1)%30))
  }
})

K.slide = function(){
  var tops
  var length
  var index = 0
  var togglers = []

  return {
    init: function(){
      tops = $$('.spread_banner')
      length = tops.length
      var el
      for(var i=0; i<length; i++){
        el = new Element('span', {}).inject($$('.slide_togglers')[0])
        el.addEvent('click', function(j){
          return function(){
            this.show(j)
          }.bind(this)
        }.call(this, i))
        togglers[i] = el
        i==0 && el.addClass('highlight')
      }
    },
    show: function(i){
      tops.setStyle('z-index', 1)
      tops[index].setStyle('z-index', 2)
      togglers[index].removeClass('highlight')
      index = i
      tops[index] || (index = 0)
      tops[index].setStyle('z-index', 3).show()
      tops[index].getElement('img') &&
        tops[index].getElement('img').fade('hide').fade('in')
      togglers[index].addClass('highlight')
    },
    next: function(){
      this.show.call(this, index+1)
    },
    start: function(){
      setInterval(this.next.bind(this), 5000)
    }
  }
}()

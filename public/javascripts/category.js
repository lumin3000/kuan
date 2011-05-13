document.addEvent('domready', function(){
  //
  setInterval((function(){
    var tops = $$('.spread_banner')
    var length = tops.length
    var index = 0
    return function(){
      tops.setStyle('z-index', 1)
      tops[index].setStyle('z-index', 2)
      ++index>=length && (index=0)
      tops[index].setStyle('z-index', 3).show()
      tops[index].getElement('img').fade('hide').fade('in')
    }
  })(), 5000)

  //
  var el = $$('.categories_box')[0]
  var cat = new Fx.Scroll(el, {
    duration: 1500,
    transition:Fx.Transitions.Quad.easeInOut
  })
  $$('.left').addEvent('click', function(){
    cat.start(el.getScroll().x-600, 0)
  })
  $$('.right').addEvent('click', function(){
    cat.start(el.getScroll().x+600, 0)
  })

  //
  var bubbles = $$('.category_list a')
  var sea = new Element('div', {
    'class': 'spread_tag'
  }).inject($$('.category_list')[0], 'after')
  for(var i=0,l=bubbles.length; i<l; i++){
    bubbles[i].inject(sea).addClass('bubble'+(i+1))
  }
})

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
      tops[index].getElement('img') &&
        tops[index].getElement('img').fade('hide').fade('in')
    }
  })(), 5000)

  //
  var el = $$('.categories_box')[0]
  var cat = new Fx.Scroll(el, {
    duration: 1500,
    transition:Fx.Transitions.Quad.easeInOut
  })
  $$('.spread_prev').addEvent('click', function(){
    cat.start(el.getScroll().x-600, 0)
  })
  $$('.spread_next').addEvent('click', function(){
    cat.start(el.getScroll().x+600, 0)
  })
  $$('.categories_inner').setStyle('width', $$('.categories_inner .row').length*100)

  //
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

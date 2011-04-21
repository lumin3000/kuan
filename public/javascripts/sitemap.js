document.addEvent('domready', function(){
  var area = [
    {'top':45, 'bottom':80, 'left':244, 'right':360},
    {'top':100, 'bottom':170, 'left':142, 'right':500},
    {'top':188, 'bottom':250, 'left':311, 'right':580},
    {'top':140, 'bottom':214, 'left':600, 'right':650},
    {'top':270, 'bottom':310, 'left':480, 'right':560}
  ]
  area.each(function(i){
    $('blog_list').getElement('div').inject($$('.nav')[0]).setStyles({
      'position': 'absolute',
      'top': Number.random(i.top, i.bottom), 
      'left': Number.random(i.left, i.right)
    })
  })
  $$('.sub').addEvents({
    'mouseenter': function(){
      $$('.note_'+this.get('name')).fade('in')
    },
    'mouseleave': function(){
      $$('.note_'+this.get('name')).fade('out')
    }
  })
})

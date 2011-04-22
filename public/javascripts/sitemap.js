document.addEvent('domready', function(){
  var area = [
    {'top':45, 'bottom':80, 'left':244, 'right':360},
    {'top':100, 'bottom':170, 'left':142, 'right':500},
    {'top':188, 'bottom':250, 'left':311, 'right':580},
    {'top':140, 'bottom':214, 'left':600, 'right':650},
    {'top':270, 'bottom':310, 'left':480, 'right':560}
  ]
  area.each(function(i){
    var item = $('blog_list').getElement('a').inject($$('.nav')[0])
    item.setStyles({
      'position': 'absolute',
      'top': Number.random(i.top, i.bottom), 
      'left': Number.random(i.left, i.right)
    })
    var img = item.getElement('img')
    var fx = new Fx.Morph(img, {
      duration: 'short',
      link: 'cancel'
    })
    img.setStyles({
      'height': 16,
      'width': 16
    }).addEvents({
      'mouseenter': function(){
        fx.start({'height':48, 'width':48})
      },
      'mouseleave': function(){
        fx.start({'height':16, 'width':16})
      }
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

document.addEvent('domready', function(){
  var i = 1
  $$('.activity .item').each(function(item){
    var count = item.get('title').replace(/.*:\s/, '')
    item.getElement('div').setStyle('height', trend_height(count))
    i++%2 == 1 && item.addClass('odd')
  });
  K.puzzle.init().auto()
})

function trend_height(n){
  if(!n)n=0
  return Math.min(n*2+1, 40)
}

K.puzzle = (function(){
  var box
  var els
  var els_show = []
  var column = 6
  var row = 3
  var size = {x:150, y:150}
  return {
    init: function(){
      box = $$('.tag_wall')[0]
      els = box.getElements('.item')
      this.init_pos()
      return this
    },
    init_pos: function(){
      box.setStyle('position', 'relative')
      for(var i=0; i<row; i++){
        els_show[i] = []
        for(var j=0; j<column; j++){
          els_show[i][j] = els.pop().setStyles({
            position: 'absolute',
            top: i*size.y,
            left: j*size.x
          })
        }
      }
      els.each(function(item){
        item.setStyles({
          position: 'absolute',
          top: -999
        })
      })
    },
    pick: function(){
      return {x:Number.random(0, column-1), y:Number.random(0, row-1)}
    },
    auto: function(){
      setInterval(this.run.bind(this), 3000)
    },
    run: function(){
      var pos = this.pick()
      this.random(pos.y, pos.x)
    },
    random: function(i, j){
      var xy = ['x','y'][Number.random(0,1)]
      var rel = [-1,1][Number.random(0,1)]
      var el = els_show[i][j]
      var els_random = Number.random(0, els.length-1)
      var el_new = els[els_random]
      el.setStyle('z-index', 999)
      el_new.setStyles({
        top: el.getStyle('top'),
        left: el.getStyle('left'),
        'z-index': 1
      })
      els_show[i][j] = el_new
      var tmp = {x:'left', y:'top'}[xy]
      var tmp2 = el.getStyle(tmp).toInt()+rel*size[xy]
      var fx = new Fx.Tween(el).addEvents({
        transition: Fx.Transitions.Quad.easeInOut,
        complete: function(){
          var next
          if(xy == 'x'){
            next = {x:j+rel , y: i}
            if(next.x<0 || next.x >= column){
              els[els_random] = el
              return
            }
          }else{
            next = {x:j , y: i+rel}
            if(next.y<0 || next.y >= row){
              els[els_random] = el
              return
            }
          }
          els[els_random] = els_show[next.y][next.x].setStyles({
            'left':-999,
            'z-index': 0
          })
          els_show[next.y][next.x] = el.setStyles({
            'z-index': 1
          })
        }
      })
      fx.start(tmp, tmp2)
    }
  }
})()

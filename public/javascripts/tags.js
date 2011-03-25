document.addEvent('domready', function(){
  var i = 1
  $$('.activity .item').each(function(item){
    var count = item.get('title').replace(/.*:\s/, '')
    item.getElement('div').setStyle('height', trend_height(count))
    i++%2 == 1 && item.addClass('odd')
  });
  /*
  $$('.tag_wall')[0].getElements('.text').each(function(item){
    item.addClass('bg'+Number.random(1,5))
  });*/
  
  if(document.location.href.indexOf('#p')>0){
    K.puzzle.init().auto()
  }else{
    K.left2right.init().auto()
  }
})

function trend_height(n){
  if(!n)n=0
  return Math.min(n+1, 28)
}

K.left2right = (function(){
  var box
  var box_bak
  var column = 6
  var row = 3
  var size = {x:150, y:150}
  var lock = false
  var now = 0
  fxs = []
  return {
    init: function(){
      box = $$('.tag_wall')[0]
      this.init_pos()
      return this
    },
    init_pos: function(){
      var box_line
      var els = box.getElements('.item')
      for(var i=0; i<row; i++){
        box_line_outer = new Element('div', {'class': 'box_line_outer'})
          .setStyles({height:size.y, width:size.x*column, overflow:'hidden'})
          .inject(box)
        box_line = new Element('div', {'class': 'box_line'})
          .setStyles({width: 3333})
          .inject(box_line_outer)
        fxs.push(new Fx.Scroll(box_line_outer, {
          duration: 1500,
          transition:Fx.Transitions.Quad.easeInOut
        }))
        for(var j=0; j<column; j++){
          els.pop().inject(box_line)
        }
      }
      box_bak = new Element('div', {'class': 'box_bak'}).hide()
        .inject(box)
      els.each(function(item){
        item.inject(box_bak)
      });
      this.reset_radius()
    },
    reset_radius: function(status){
      status = status || 'all'
      if(status=='all' || status=='start'){
      box.getElements('.item.left').removeClass('left')
      box.getElement('.box_line .item').addClass('left')
      }
      if(status=='all' || status=='end'){
      box.getElements('.item.right').removeClass('right')
      box.getElement('.box_line').getElements('.item')[column-1].addClass('right')
      }
    },
    auto: function(){
      setInterval(this.run.bind(this), 8000)
    },
    run: function(){
      var box_line_outer = box.getElements('.box_line_outer')[now]
      var box_line = box_line_outer.getElement('.box_line')
      var els_random = Number.random(0, box_bak.getElements('.item').length-1)
      var el_new = box_bak.getElements('.item')[els_random]
      el_new.inject(box_line, 'top')
      if(!Browser.ie6){
        box_line_outer.scrollLeft = size.x
        this.reset_radius('start')
        fxs[now].toLeft().chain(function(){
          this.reset_radius('end')
          box_line.getElements('.item').getLast().inject(box_bak)
        }.bind(this))
      }else{
          box_line.getElements('.item').getLast().inject(box_bak)
      }
      now++
      if(now>=row){
        now = 0
      }
    }
  }
})()

K.puzzle = (function(){
  var box
  var els
  var els_show = []
  var column = 6
  var row = 3
  var size = {x:150, y:150}
  var lock = false
  return {
    init: function(){
      box = $$('.tag_wall')[0]
      els = box.getElements('.item')
      this.init_pos()
      return this
    },
    // random
    auto: function(){
      setInterval(this.random.bind(this), 2000)
    },
    random: function(){
      var pos = this.pick()
      var xy = ['x','y'][Number.random(0,1)]
      var rel = [-1,1][Number.random(0,1)]
      this.run(pos.y, pos.x, xy, rel)
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
      });
      this.reset_radius()
    },
    pick: function(){
      return {x:Number.random(0, column-1), y:Number.random(0, row-1)}
    },
    reset_radius: function(){
      box.getElements('.item.left').removeClass('left')
      box.getElements('.item.right').removeClass('right')
      els_show[0][0].addClass('left')
      els_show[0][column-1].addClass('right')
    },
    run: function(i, j, xy, rel){
      if(lock == true)return
      lock = true
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
          lock = false
          var next
          if(xy == 'x'){
            next = {x:j+rel , y: i}
            if(next.x<0 || next.x >= column){
              els[els_random] = el
              this.reset_radius()
              return
            }
          }else{
            next = {x:j , y: i+rel}
            if(next.y<0 || next.y >= row){
              els[els_random] = el
              this.reset_radius()
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
          this.reset_radius()
        }.bind(this)
      })
      fx.start(tmp, tmp2)
    }
  }
})()


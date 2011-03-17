document.addEvent('domready', function(){
  var i = 1
  $$('.activity .item').each(function(item){
    console.log(item.get('title'))
    var count = item.get('title').replace(/.*:\s/, '')
    item.getElement('div').setStyle('height', trend_height(count))
    i++%2 == 1 && item.addClass('odd')
  })
})

function trend_height(n){
  if(!n)n=0
  return Math.min(n*2+1, 40)
}

K.puzzle = (function(){
  return {
    init: function(){
    },
    move: function(){
    }
  }
})()

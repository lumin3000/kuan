document.addEvent('domready', function(){
  $$('.activity .item').each(function(item){
    console.log(item.get('title'))
    var count = item.get('title').replace(/.*:\s/, '')
    item.getElement('div').setStyle('height', trend_height(count))
  })
})

function trend_height(n){
  if(!n)n=0
  return Math.min(n*2+1, 40)
}

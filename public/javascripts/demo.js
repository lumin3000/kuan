K.emotion = function(el, textarea){
  var tt = $(textarea)
  emotions = ['o(∩_∩)o', '(^_^;)', '(*^^)v', '(*^_^*)', '(￣.￣)', '（┬＿┬）', '(~_~)', 'm(_ _)m']
  emotions.each(function(item){
    new Element('span', {
      'html':item
    }).setStyles({
      'border': '1px solid gray',
      'background': 'lightgray',
      'display': 'inline-block',
      'padding': 3,
      'margin': 3
    }).inject(el).addEvent('click', function(){
      var str = "#" + this.innerHTML + "#"
      tt.focus()
      if(typeof document.selection != "undefined"){
        document.selection.createRange().text = str
      }else{
        tt.value = tt.value.substr(0, tt.selectionStart) + str
          + tt.value.substr(tt.selectionStart, tt.value.length)
      }
      tt.blur()
    })
  })
}

document.addEvent('domready', function(){
  $('emotion') && K.emotion($('emotion'), $$('textarea')[0])
})

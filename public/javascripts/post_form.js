K.widgets.changeTag = function(el){
  el.addEvent('change', function(e){
    var v = this.options(this.selectedIndex).get('data-tags')
    var textbox = $$('.tags')[0].textboxlist
    if(!v) return
    if(textbox.original.value != textbox.default_value) return
    $$('.tags')[0].textboxlist.reset(v)
  })
}

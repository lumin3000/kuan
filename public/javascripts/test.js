pp = (function(){
  var a
  var s
  var domain
  var old_page
  init_page = function(){
    var m = document.URL.match(/\/page\/(\d+)/)
    if(m){
      return m[1]
    }else{
      return 1
    }
  }
  g_url = function(page){
    return 'http://'+domain+'/page/'+page
  }
  set_data = function(el, newer){
    var els = el.getElements('.post') 
    while(els.length > 0){
      console.log('-')
      if(newer){
        els.pop().each(function(item){
          a.push({o: item.get('value')})
        })
      }else{
        while(els.length > 0){
        a.unshift({o: els.shift().get('value')})
      }
    }
  }

  get_old = function(){
    var p = old_page + 1
    new Request.HTML({
      'url': g_url(p),
      'method': 'get',
      'evalScripts': false,
      'onSuccess': function(tree, els){
         set_data(els[0])
         old_page = p
      }
    }).send()
  }

  load_img = function(){
    if(a.length == 0)return
    var i = a.shift()
    Asset.image(i.o, {
      onLoad: function(){
        console.log('load: '+i.o)
        load_img()
      }
    }).inject(s, 'bottom')
  }

  return {
    init: function(){
      a = []
      s = new Element('div').inject(document.body)
      domain = document.domain
      old_page = new_page = init_page()
      set_data(document.body.getElement('.data'))
      load_img()
    }
  }
})()

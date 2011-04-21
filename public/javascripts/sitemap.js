document.addEvent('domready', function(){
  $$('.sub').addEvents({
    'mouseenter': function(){
      $$('.note_'+this.get('name')).fade('in')
    },
    'mouseleave': function(){
      $$('.note_'+this.get('name')).fade('out')
    }
  })
})

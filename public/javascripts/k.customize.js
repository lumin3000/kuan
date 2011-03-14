K.widgets.appearance = function(el){
  el.addEvents({
    'click': function(){
    },
    'click:relay(.color_pick)': function(e){
      var el = e.target
      function setColor(color, preview){
        var par = el.getParent('.colors')
        el.setStyle('background-color', color.hex)
        par.getElement('input').set('value', color.hex)
        if(preview){
          el.getParent('form').diverseSubmit()
        }
      }
      new MooRainbow(el, {
        id: 'moorainbow_'+Number.random(1,9999),
        startColor: new Color(el.getStyle('background-color')),
        imgPath: '/images/moorainbow/',
        onChange: function(color){
          setColor(color)
        },
        onComplete: function(color){
          setColor(color, true)
        }
      })
      el.fireEvent('click')
    },
    'click:relay(.cleaner)': function(e){
      e.stop()
      var el = e.target.getParent('.images')
      var tar_url = el.getElement('.url')
      el.removeClass('image_exist').addClass('image_empty')
      tar_url.value = ''
      el.getParent('form').diverseSubmit()
    }
  })
  el.getElements('input.uploader').each(init_uploader)

}

K.widgets.reload_appearance = function(el){
  el.addEvent('click', function(){
    var form = el.getParent('form')
    var fieldset_appearance = $$('fieldset.appearance')[0]
    var box = fieldset_appearance.getElement('.box')
    new Request.HTML({
      url: '/extract_template_vars',
      method: 'post',
      update: box,
      useSpinner: true,
      spinnerTarget: fieldset_appearance,
      data: {
        'blog[using_custom_html]': form.getElement('[name=blog[using_custom_html]]').value,
        'blog[template_id]': form.getElement('[name=blog[template_id]]') && form.getElement('[name=blog[template_id]]').value,
        'blog[custom_html]': form.getElement('[name=blog[custom_html]]').value
      },
      onComplete: function(){
        form.diverseSubmit()
        box.getElements('input.uploader').each(init_uploader)
      }
    }).send()
  })
}

init_uploader = function(el){
  var parent = el.getParent('.images')
  var tar_url = parent.getElement('.url')
  new K.file_uploader(el, '/upload/photo', {
    'fire_now': true,
    'onStart': function(){
    },
    'onSuccess': function(v){
      parent.removeClass('image_empty').addClass('image_exist')
      tar_url.value = v.image.original
      parent.getParent('form').diverseSubmit()
    }
  })
}

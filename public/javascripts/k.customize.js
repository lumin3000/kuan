K.widgets.tab = (function() {
  var ACTIVATION_CLASS = 'activated'
    , Tab = new Class({
        Implements: [Events]
      , initialize: function(label, content) {
          this.label = label
          if (content) this.mountContent(content)
          this.activated = false
        }
      , mountContent: function(content) {
          var self = this
          this.content = content
          this.label.addEvent('click', function(e) {
            e.stop()
            self.toggle()
          })
          return this
        }
      , toggle: function() {
          if (this.activated) this.deactivate()
          else this.activate()
        }
      , activate: function() {
          this.activated = true
          this.label.addClass(ACTIVATION_CLASS)
          this.content.addClass(ACTIVATION_CLASS)
          this.fireEvent("activate")
          return this
        }
      , deactivate: function() {
          this.activated = false
          this.label.removeClass(ACTIVATION_CLASS)
          this.content.removeClass(ACTIVATION_CLASS)
          this.fireEvent("deactivate")
          return this
        }
      })

    , TabSet = new Class({
        initialize: function(tabs) {
          tabs.each(this.listenTab, this)
          this.tabs = tabs
          this.activated = {deactivate: function() {}}
        }
      , listenTab: function(tab) {
          var tabSet = this
          tab.addEvent('activate', function() {
            if (this != tabSet.activated) tabSet.activated.deactivate()
            tabSet.activated = this
          })
        }
      })
  TabSet.buildFrom = function(labels, contents) {
    var tabs = []
    labels.each(function(label, index) {
      var tab = new Tab(label, contents[index])
      tabs.push(tab)
    })
    return new TabSet(tabs)
  }

  return function(labelList) {
    var labels = labelList.getChildren()
      , contentsHolder = document.getElement(labelList.get("data-contentsHolder"))
      , contents = contentsHolder.getChildren(labelList.get("data-contents"))
      , index = parseInt(labelList.get('data-activateOnLoad'), 10)
    // Expose to global
    customizePanel = TabSet.buildFrom(labels, contents)
    var name = labelList.get('data-name')
    if(name){
      K.widgets.tab[name] = customizePanel
    }
    if (!isNaN(index)) {
      var tabToActivate = customizePanel.tabs[index]
      if (tabToActivate) tabToActivate.activate()
    }
  }
})()

K.widgets.diverseSubmit = function(button) {
  var form = $(button.getParent('form'))
    , newTarget = button.get('data-target')
    , newAction = button.get('data-action')
    , newMethod = button.get('data-methord')
    , oldAction = form.action
    , oldTarget = form.target
    , overridingMethod = form.getElement('input[name=_method]')
    , oldMethod = overridingMethod ? overridingMethod.get('value') : form.get('method')

  if (!overridingMethod) {
    overridingMethod = new Element('input', {
      name: '_method'
    , type: 'hidden'
    , value: oldMethod
    })
    form.grab(overridingMethod)
  }

  form.diverseSubmit = function(callback){
    form.set({
      action: newAction
      , target: newTarget
    })
    overridingMethod.set('value', newMethod)
    form.submit()
    callback && callback()
    form.set({
      action: oldAction
      , target: oldTarget
    })
    overridingMethod.set('value', oldMethod)
  }

  button.addEvent('click', function(e) {
    e.stop()
    form.diverseSubmit()
  })
}

K.widgets.submit = function(button) {
  var form = document.getElement(button.get('data-form'))
  if (!form || form.nodeName.toLowerCase() != 'form') return
  button.addEvent('click', function(e) {
    e.stop()
    form.submit()
  })
}

K.widgets.radioButton = function(context) {
  var form = context.getParent('form')
  if (!form) return
  var childSelector = context.get('data-contents')
    , fieldName = context.get('data-fieldName')
    , selected = context.getElement('.selected')
    , input = new Element('input', {
        name: fieldName
      , id: fieldName.replace(/[[\]]/g, function(matched) {
          return {
            '[': '_'
          , ']': ''
          }[matched]
        })
      , type: 'hidden'
      , value: selected.get('data-value')
      }).inject(form)

  context.delegate("click", childSelector, function(e) {
    e.stop()
    if (e.target == selected) return
    var value = e.target.get('data-value')
    input.set('value', value)
    selected.removeClass('selected')
    selected = e.target.addClass('selected')
  })
}

K.widgets.toggler = function(button) {
  var target = document.getElement(button.get('data-target'))
  if (!target) return
  var classes = button.get('data-classes').split(' ')
    , input = document.getElement('input[name='+ button.get('data-field') +']')
    , customHtml = $(input.form).getElement('[name=blog[custom_html]]')
    , initialValue = customHtml.get('value')

  button.addEvent('click', function(e) {
    e.stop()
    var isUsingCustomHtml = input.get('value') == 1 ? 0 : 1
    classes.each(function(c) { target.toggleClass(c) })
    input.set('value', isUsingCustomHtml)
    if (!isUsingCustomHtml) return

    var tplId = $('blog_template_id').get('value')
    if (!tplId) {
      customHtml.set('value', initialValue)
      return
    }
    customHtml.set('disabled', true)
    new Request({
      method: 'GET'
    , url: '/templates/' + tplId
    , noCache: true
    , onSuccess: function(tplHtml) {
        customHtml.set({
          disabled: false
        , value: tplHtml
        })
      }
    }).send()
  })
}

K.widgets.preview = function(context) {
  var form = new Element('form', {
    action: '/preview'
  , method: 'POST'
  , target: 'preview'
  })
    , tplId = new Element('input', {
        type: 'hidden'
      , name: 'blog[template_id]'
      })
  form.grab(new Element('input', {
    type: 'hidden'
  , name: 'blog[using_custom_html]'
  , value: 0
  })).grab(tplId)

  context.delegate('click', '.theme', function(e) {
    e.stop()
    tplId.value = e.target.get('data-value')
    form.submit()
  })
}

K.widgets.checkbox_preview = function(el){
  el.addEvent('click', function(){
    el.getParent('form').diverseSubmit()
  })
}

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

document.addEvent('domready', function() {
  var previewFrame = $('preview')
    , resizeLock = false
    , preservedHeight = $('customize_panel').getSize().y
  window.addEvent('resize', adjustSize)
  ;[document.body, $('container')].each(function(el) {
    el && el.setStyle('overflow', 'hidden')
  })
  adjustSize()

  function adjustSize() {
    if (resizeLock) return
    resizeLock = true
    setTimeout(function() {
      resizeLock = false
      previewFrame.setStyle('height', window.getSize().y - preservedHeight)
    }, 80)
  }
})

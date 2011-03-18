Element.implement({
  delegate: function(type, selector, fn) {
    if (typeOf(fn) != 'function') {
      throw new Error('Must provide a callback function')
    }
    this.addEvent(type, function(e) {
      var target = $(e.target)
      if (target.match(selector)) return fn.call(this, e)

      while (target != this && !target.match(selector)) {
        target = target.getParent()
      }
      e.target = target
      if (target != this) fn.call(this, e)
    })
    return this
  }
})

K = {
  log: function() {
    if (typeof console != "undefined") {
      return console.log.apply(console, arguments)
    }
    var body = document.body
      , text = Array.prototype.join.call(arguments, " ")
    body.appendChild(document.createElement("br"))
    body.appendChild(document.createTextNode(text))
  }
}

K.upload_log = function(msg){
  msg = Browser.name+Browser.version+' : '+Browser.Platform.name + ' : ' + msg
  new Request({
    url: '/upload_log',
    method: 'post',
    data: {'info':msg},
    onComplete: function(){
    }
  }).send()
}
K.file_uploader = new Class({
    Implements: [Options],

    options: {
        /*
        onStart: nil,
        onCancel: nil,
        onSuccess: nil,
        onFailure: nil
        */
        multiple: false,
        limit: 10,
        type: 'image/*',
        tar: null
    },

    initialize: function(el, path, options){
        this.file = $(el)
        this.path = path
        if(!this.file){
            throw new Error('shCan not find file element')
        }
        if(!path){
            throw new Error('')
        }
      this.setOptions(options)
      this.multiple = this.options.multiple && (typeof FormData != 'undefined')
      this.file.set('accept', this.options.type)
      if(this.multiple){
        this.file.multiple = 'multiple'
      }
        var tar = $(this.options.tar)
        var fire_now = this.options.fire_now
        if(tar == null){
            this.file_box = new Element('div', {
            }).setStyles({
                'display':'inline'
              }).inject(this.file, 'before')
            this.file.inject(this.file_box)
        }else{
            /*
            tar = new Element('a', {
                'html':'上传',
                'href':'#'
            });*/
            var tar_size = tar.getComputedSize()

            this.file_box_outer = new Element('div', {
            }).inject(this.file, 'before').setStyles({
                'height':30,
                'width':120,
                'display':'inline'
            })

            this.file_box = new Element('span', {
            }).inject(this.file_box_outer).setStyles({
                'overflow':'hidden',
                'position':'absolute',
                'height':tar_size.totalHeight,
                'width':tar_size.totalWidth,
                'font-size':12
            })
            this.file.setStyles({
                'position':'absolute',
                'z-index':'100',
                'margin-left':'-180px',
                'font-size':30,
                'margin-top':'-5px',
                'opacity':0,
                'filter':'alpha(opacity=0)',
                'visibility':'visible'
            }).inject(this.file_box)
            tar.inject(this.file_box)
        }
        this.file_clone = this.file.clone()
        this.file.destroy()
        this.build_file()
        this.file.set('disabled', false)
      if(fire_now){
        this.file.fireEvent('click')
      }
    },
  build_file: function(){
    this.file = this.file_clone.inject(this.file_box, 'top')
    //    .set('disabled', true)
    this.file_clone = this.file_clone.clone()
    this.file.addEvents({
      'change': function(){
        this.start()
      }.bind(this),
      'mouseenter': function(){
        //this.file_box.getElement('a').fireEvent('mouseover')
      },
      'mouseleave': function(){
        //this.file_box.getElement('a').fireEvent('mouseleave')
      }
    })
  },
  start: function(){
    if(this.file.get('disabled') == true || this.file.value == ''){
      return false
    }
    if(!this.multiple){
      K.upload_log(this.path+' : start : single')
      var f_tar = '_fff_'+Number.random(1,9999)
      this.frame = new Element('iframe', {'id': f_tar, 'name': f_tar}).
        inject(document.body).
        setStyles({
          'position': 'absolute',
          'top': '-1000px',
          'left': '-1000px'
        })

      this.form = new Element('form', {
        'action': this.path,
        'accept-charset': 'UTF-8',
        'enctype': 'multipart/form-data',
        'encoding': 'multipart/form-data',
        'method': 'post',
        'target': f_tar
      }).inject(document.body).hide()
      this.file.inject(this.form)
      this.build_file()
      setTimeout(function(){
        this.frame.addEvent('load', function(){
          this.complete()
        }.bind(this))
        this.form.submit()
      }.bind(this), 50)
      this.options.onStart &&
        this.options.onStart()
    }else{
      for(var i=0, l = Math.min(this.file.files.length, this.options.limit); i<l; i++){
        K.upload_log(this.path+' : begin : multi')
        var el = this.options.onStart && this.options.onStart()
        this.html5upload.call(this, this.file.files[i], el)
      }
      this.file.destroy()
      this.build_file()
    }
  },
  html5upload: function(file, el){
    var form_data = new FormData()
    form_data.append('file', file)
    var xhr = new XMLHttpRequest()
    var spin = el.set('spinner', {message: '上传中'}).spin()
    xhr.addEventListener('error', function(e){
      el.unspin()
      el.destroy()
    }, false)
    xhr.addEventListener('load', function(e){
      if(xhr.readyState==4 && xhr.status==200){
        this.complete(xhr.responseText, el)
        el.unspin()
      }
    }.bind(this), false)
    xhr.addEventListener('progress', function(e){
      function status(n){
        el.get('spinner').msg.set('html', n)
      }
      if(e.lengthComputable){
        status(''+(e.loaded/e.total*100).toInt()+'%')
      }
    }.bind(this), false)
    xhr.open('POST', this.path, true)
    xhr.send(form_data)
  },
  cancel: function(){
  },
  complete: function(response, el){
    var v
    if(!this.multiple){
      v = this.frame.contentWindow.document.body.innerHTML
      v = JSON.decode(v)
      this.success.call(this, v, el)
      this.form.destroy()
      document.body.removeChild(this.frame)
    }else{
      v = JSON.decode(response)
      this.success.call(this, v, el)
    }
    this.file.set('disabled', false)
  },
  success: function(v, el){
    K.upload_log(this.path+' : success')
    this.options.onSuccess &&
      this.options.onSuccess(v, el)
  }
})

K.editor = null
K.render_editor = function(el, fix){
    var textarea = $(el)
    var fix = fix || {width:0, height: 0}
    var w  = textarea.getStyle('width').toInt() + fix.width
    var h  = textarea.getStyle('height').toInt() - fix.height
    K.editor = new MooEditable(textarea, {
        'actions':'toggleview | bold italic underline strikethrough | createlink unlink | urlimage ',
        'dimensions':{x:w,y:h},
        'rootElement':''
    })
}

K.blog  = (function(){

    return {
        init_upload_icon: function(){
            new K.file_uploader($('image_uploader'), '/upload/blog_icon', {
                'onStart': function(){
                    $('blog_icon_feed').innerHTML = '上传中,请稍候...'
                },
                'onSuccess': function(v){
                    $('blog_icon_feed').innerHTML = '上传成功'
                    $('blog_icon_id').value = v.image.id
                    $('blog_icon_img').set('src', v.image.medium)
                }
            })
        }
    }
})()

K.post = (function(){
    var photo_path = '/upload/photo'
    var init_title = function(){
        $$('.new_title_starter').addEvent('click', function(){
            $$('.title_text')[0].show()
            this.hide()
            return false
        })
    }

    var photo_item_template
    var photo_item = {
        create: function(){
            var el = photo_item_template.clone()
            el.getElement('[name=tar_img]').set('src', '/images/default_photo.jpg')
            el.inject($('photos_list'))
            this.process(el)
            photo_item.attach(el)
            photos_list_sort.addItems(el)
            el.getElement('.the_text input').hide()
            return el
        },
        process: function(el){
        },
        success: function(v, el){
            el.getElement('.the_image a')
                .set('href', v.image.original)
            el.getElement('[name=tar_img]')
                .set('src', v.image.small)
            el.getElement('.the_text input')
                .show()
            el.getElement('.image_id')
                .set('value', v.image.id)
            el.getElement('[name=tar_process]').hide()
        },
        failure: function(el, v){
            $$('.post_error')[0].innerHTML = v.message
            el.distroy()
        },
        attach: function(el){
            el.getElement('.the_close').addEvent('click', function(){
                var photo_item = this.getParent('[name=photo_item]')
                /*
                if(photo_item.getElement(['[name=tar_process]']) && photo_item.getElement(['[name=tar_process]']).isDisplayed()){
                }*/
                photo_item.destroy()
            })
        }
    }
    var init_upload = function(){
      var el
        new K.file_uploader($('image_uploader'), photo_path, {
            'multiple': true,
            'onStart': function(){
              el = photo_item.create()
              return el
            },
          'onSuccess': function(v, ele){
              photo_item.success(v, ele||el)
            }
        })
    }
    var photos_list_sort
    var init_photo_items = function(){
        photos_list_sort = new Sortables($('photos_list'), {
            handle:'.the_drag_handle',
            clone:true
        })
        $$('[name=photo_item]').each(function(item){
            photos_list_sort.addItems(item)
        })
        $$('[name=photo_item]').each(function(item){
            photo_item.attach(item)
        })
    }

    var init_toggle_upload = function(){
        var tar_tog_url = $('tar_tog_url')
        var tar_tog_local = $('tar_tog_local')
        var box_file = $('box_file')
        var box_url = $('box_url')
        tar_tog_url.addEvent('click', function(){
            tar_tog_url.hide()
            tar_tog_local.show()
            box_file.hide()
            box_url.show()
            OverText.instances.each(function(item){
                item.reposition()
            })
        })
        tar_tog_local.addEvent('click', function(){
            tar_tog_url.show()
            tar_tog_local.hide()
            box_file.show()
            box_url.hide()
        })
    }

    var init_editor = function(){
        if($$('.text')[0] && $$('.text')[0].hasClass('rich_text')){
          K.render_editor($('content'), {width:55, height:50})
        }
        $$('.rich_editor_starter').addEvent('click', function(){
            this.hide()
            $('box_text').addClass('rich_text')
            K.render_editor($('content'), {width:55, height:50})
            return false
        })
        if($('tar_tog_textarea')){
            init_toggle_textarea()
        }
    }

    var init_toggle_textarea = function(){
        var tar_tog_textarea = $('tar_tog_textarea')
        var tar_tog_textarea_close = $('tar_tog_textarea_close')
        var box_text = $('box_text')
        if(box_text.isDisplayed()){
            tar_tog_textarea.hide()
            tar_tog_textarea_close.show()
        }
        tar_tog_textarea.addEvent('click', function(){
            tar_tog_textarea.hide()
            tar_tog_textarea_close.show()
            box_text.show()
            return false
        })
        tar_tog_textarea_close.addEvent('click', function(){
            tar_tog_textarea.show()
            tar_tog_textarea_close.hide()
            box_text.hide()
            K.editor.setContent('')
            return false
        })
    }
    return {
        init: function(){
            init_title()
            init_editor()

            if($('photos_list')){
                var tmpl = $('photo_template').value;
                tmpl = tmpl.replace(/&apos;/gm, '"');
                photo_item_template = Elements.from(tmpl)[0]
                init_photo_items()
                if($('image_uploader') && $('photo_template')){
                    init_upload()
                }
                this.init_url_upload()
                init_toggle_upload()
            }
        },
        init_url_upload: function(){
            new OverText($('url_uploader_url'))
            $('url_uploader_btn') && $('url_uploader_btn').addEvent('click', function(){
                var url = $('url_uploader_url').value
                var el = photo_item.create()
                photo_item.attach(el)
                new Request.JSON({
                    url: photo_path,
                    method: 'post',
                    data: {'url':url},
                    onComplete: function(result){
                        if(result.status == 'error'){
                            photo_item.failure(el, result)
                        }else{
                            $('url_uploader_url').value = ''
                            OverText.instances.each(function(item){
                                item.reposition()
                            })
                            photo_item.success(result, el)
                        }
                    }
                }).send()

            })
        }
    }
})()

K.widgets = {}
K.widgets.env = {
  post_single: false
}
K.widgets.shrinked = function(elem) {
  var context = elem
    , triggers = context.getElements(context.get('data-trigger'))
  triggers.addEvent('click', function(e) {
    e.stop()
    context.toggleClass('shrinked')
  })
}

K.widgets.fixHover = (function() {
  var className = 'hover'
    , events = {
        mouseenter: function() { $(this).addClass(className) }
      , mouseleave: function() { $(this).removeClass(className) }
      }
  return function(elem) { elem.addEvents(events) }
})()

document.addEvent('domready', function(){
  if($(document.body).hasClass('post_single')){
    K.widgets.env.post_single = true
  }
  var KEY = 'data-widget'
  $$('[' + KEY + ']').each(function(e){
    var types = e.get(KEY)
    if (types) types = types.split(' ')
    else return
    types.each(function(t) {
      var func = K.widgets[t]
      func && func(e)
    })
  })

  $(document.body).addEvent('click:relay([data-tgt])', function(e){
    var tgt = e.target.get('data-tgt')
    var func
    if(tgt){
      e.stop()
      func = K.tgt[tgt]
      func && func(e.target)
    }
  })

    // lightbox
    if($$('[rel=lightbox]').length > 0){
        new Asset.javascript('/javascripts/cerabox.js', {
            onload: function() {
                var box = new CeraBox({group: false});
                box.addItems('[rel=lightbox]', {
                    animation: 'ease'
                });
                new Asset.css('/stylesheets/cerabox.css')
            }
        })
    }
})

K.widgets.rest = function() {
  var callbackDict = {
    redirect: function(response) {
      var target = response && response.location
      if (target) window.location = target
    },
    refresh: function(response){
        window.location = window.location
    },
    del: function(response, el){
      var parent = el.getParent('.'+el.get('data-parent'))
      parent && parent.destroy()
    },
    del_self: function(response, el){
      el.destroy()
    },
    replace: function(response, el){
      if(el.get('data-parent')){
        var parent = el.getParent('.'+el.get('data-parent'))
        parent.empty()
        parent.innerHTML = response.message
      }else{
        new Element('span', {
          'html': response.message
        }).inject(el, 'after')
        el.destroy()
      }
    },
    toggle: function(response, el){
      var clazz = el.get('data-class')
      var title = el.get('data-title')
      el.set('data-class', el.get('class'))
      el.set('data-title', el.get('title'))
      el.innerHTML = title
      el.set('class', clazz)
      el.set('title', title)
    },
    flash: function(response){
        
    }
  }

  return function(el){
    var callback = callbackDict[el.get('data-callback') || "default"]
      , method = el.get('data-md') || 'post'
    el.addEvent('click', function(e){
      e.stop()

      var confirmMessage = el.get('data-doconfirm');
      if(confirmMessage && !confirm(confirmMessage)) {
        return false;
      }

      var link = el.get('href')
      new Request.JSON({
        url: link,
        method: method,
        useSpinner: true,
        spinnerTarget: el,
        onSuccess: function(response){
          if (callback) {
            callback(response, el)
          } else {
            alert('操作成功')
          }
        },
        onFailure: function(){
          alert('操作失败')
        }
      }).send()
    })
  }
}()

K.widgets.sugar = (function(){
    var init_flag = false;
    function init(){
        var el = new Element('div', {
            'html':'<img src="/images/top.gif" title="到顶部" />'
        }).setStyles({
            'position':'fixed','right':20,'bottom':20,'cursor':'pointer'
        }).inject($(document.body)).fade('hide');
        if(Browser.ie6){
            return;
        }
        window.addEvent('scroll', function(){
	    if(window.getScrollTop()>window.getHeight()){
	        el.fade('in');
	    }else{
                el.fade('out');
	    }
        });
        el.addEvent('click', function(){
	    new Fx.Scroll(window).toTop();
        });
    }
    return function(){
        if(!init_flag){
            init();
            init_flag = true;
        }
    };
})();

K.widgets.overtext = function(el){
  new OverText(el)
}
K.widgets.video = function(el){
    var init_flash = function(path, el){
        new Swiff(path, {
            width: 440,
            height: 360,
            container: el,
            params: {
                wMode: 'opaque'
            },
            vars: {
                isShowRelatedVideo: false,
                showAd: 0,
                isAutoPlay: true,
                playMovie: true,
                UserID: ''
            }
        })
    }
    var init_video = function(){
        el.getElement('.video_tar_open').addEvent('click', function(){
            var p = this.getParent('.post')
            p.getElement('.video_thumb').hide()
            p.getElement('.video_full').show()
            if(!p.getElement('object')){
                init_flash(
                    p.getElement('.video_tar_open').get('href'),
                    p.getElement('.video_player')
                )
            }
            return false
        })
        el.getElement('.video_tar_close').addEvent('click', function(){
            var p = this.getParent('.post')
            p.getElement('.video_thumb').show()
            p.getElement('.video_full').hide()
        })
    }

    init_video()

    if(K.widgets.env.post_single){
        el.getElement('.video_tar_open').fireEvent('click')
    }
}

K.tgt = {}

K.tgt.comments = function(){
    var comments_el
    var comments_target
    var lock = false

    return function(el){
        if(lock)return
        lock = true

        var url = el.get('href')
        var container = el.getParent('.post')
        if(comments_el){
            comments_el.destroy()
            comments_el = null
            if(comments_target.get('href') == url){
                lock = false
                return
            }
        }
        new Request.HTML({
            url: url+'?r'+Number.random(1,999),
            method: 'get',
            append: container,
            useSpinner: true,
            spinnerTarget: el,
            onSuccess: function(){
                comments_el = container.getElement('.chat')
                K.set_max_height(comments_el.getElement('.c_content'))
                comments_target = el
                if(comments_el.getElement('[name=count]').value > 0){
                    container.getElement('.reply').innerHTML = comments_el.getElement('[name=count]').value
                }
                if(comments_target.getParent('.new_reply')){
                    comments_target.getParent('.new_reply').removeClass('new_reply')
                }
                lock = false
            }
        }).send()
    }
}()

K.set_max_height = function(el){
    if(!el.getStyle('max-height') && el.getSize().y > 390){
        el.setStyle('height', 390)
    }
}

K.tgt.reply = function(){
    var lock = false

    return function(el){
        var post = el.getParent('.post')
        var chat = el.getParent('.chat')
        var f = el.getParent('form')
        var input = f.getElement('[name=content]')

        if(lock)return
        if(input.value == ''){
            input.highlight()
        }
        lock = true
        input.set('disabled', true)
        el.set('disabled', true)
        
        new Request.HTML({
            url: f.get('action'),
            method: 'post',
            data: { content: input.value},
            useSpinner: true,
            spinnerTarget: el,
            onSuccess: function(responseTree, responseElements){
                var els = responseElements[0].getChildren()
                chat.empty()
                els.each(function(item){
                    item.inject(chat)
                })
                K.set_max_height(chat.getElement('.c_content'))
                chat.getElement('.c_content').scrollTo(0, 9999)
                if(chat.getElement('[name=count]').value > 0){
                  post.getElement('.reply').innerHTML = chat.getElement('[name=count]').value                
                }

                lock = false
            }
        }).send()
    }
}()

K.widgets.textarea = function(el){
  K.render_editor(el)
}

K.widgets.textboxlist = function(el){
  el.textboxlist = new TextboxList(el, {
    bitsOptions:{editable:{
      addOnBlur: true, addKeys: [13, 188],
      growingOptions: {startWidth: 30}
    }}
  });
}

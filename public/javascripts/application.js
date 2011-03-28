;(function($){

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
    if(document.location.href.indexOf('#debug')>0){
      if (typeof console != "undefined") {
        console.log.apply(console, arguments)
      }
      var body = document.body
      , text = Array.prototype.join.call(arguments, " ")
      body.appendChild(document.createElement("br"))
      body.appendChild(document.createTextNode(text))
    }
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
            throw new Error('找不到上传按钮')
        }
        if(!path){
            throw new Error('')
        }
      this.setOptions(options)
      this.multiple = this.options.multiple && (typeof FormData != 'undefined')
      this.file.set('accept', this.options.type)
      if(this.multiple){
        this.file.multiple = 'multiple'
      }else{
        this.file.multiple = ''
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
      var el = this.options.onStart && this.options.onStart()
      setTimeout(function(){
        this.frame.addEvent('load', function(){
          this.complete(null, el)
        }.bind(this))
        this.form.submit()
      }.bind(this), 50)
    }else{
      for(var i=0, l = Math.min(this.file.files.length, this.options.limit); i<l; i++){
        K.upload_log(this.path+' : start : multi')
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
    xhr.addEventListener('error', function(e){
      this.failure.call(this, '失败', el)
    }.bind(this), false)
    xhr.addEventListener('load', function(e){
      if(xhr.readyState==4 && xhr.status==200){
        this.complete(xhr.responseText, el)
      }
    }.bind(this), false)
    xhr.addEventListener('progress', function(e){
      function status(n){
        //el && el.get('spinner').msg.set('html', n)
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
  failure: function(v, el){
    this.options.onFailure &&
      this.options.onFailure.call(this, v, el)
  },
  success: function(v, el){
    K.upload_log(this.path+' : success : '+ (this.multiple ? 'multi' : 'single'))
    this.options.onSuccess &&
      this.options.onSuccess.call(this, v, el)
  }
})

K.editor = null
K.render_editor = function(el, fix){
  var textarea = $(el)
  var fix = fix || {width:0, height: 0}
  var w  = textarea.getStyle('width').toInt() + fix.width
  var h  = textarea.getStyle('height').toInt() - fix.height
  if(K.checkMobile()){
    return
  }
  K.editor = new MooEditable(textarea, {
    'actions':'toggleview | bold italic underline strikethrough | createlink unlink | urlimage ',
    'extraCSS':'pre{white-space:pre-wrap;word-wrap:break-word;font-family: "Hiragino Sans GB", hei, "microsoft yahei";line-height:1.5}',
    'dimensions':{x:w,y:h},
    'rootElement':''
  })
}
K.editor_toolbar = {
  show: function(el){
    if(K.checkMobile()){
      $$('.rich_editor_stater')[0] && $$('.rich_editor_stater')[0].hide()
      $$('.text_editor_stater')[0] && $$('.text_editor_stater')[0].hide()
      return
    }
    var toolbar = el.getElement('.mooeditable-ui-toolbar')
    var box = el.getElement('iframe')
    el.setStyle('height', 340)
    toolbar && toolbar.show()
    box && box.setStyles({
      'margin-top': 0,
      'height': 300
    })
  },
  hide: function(el){
    if(K.checkMobile()){
      $$('.rich_editor_stater')[0] && $$('.rich_editor_stater')[0].hide()
      $$('.text_editor_stater')[0] && $$('.text_editor_stater')[0].hide()
      return
    }
    var toolbar = el.getElement('.mooeditable-ui-toolbar')
    var box = el.getElement('iframe')
    if (K.editor.mode == 'textarea'){
      K.editor.mode = 'iframe';
      K.editor.iframe.setStyle('display', '');
      K.editor.setContent(K.editor.textarea.value);
      K.editor.textarea.setStyle('display', 'none');
    }
    el.setStyle('height', 100)
    box && box.setStyles({
      'margin-top': 6,
      'height': 90
    })
    toolbar && toolbar.hide()
  }
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

K.widgets = new Events()
K.widgets.env = {
  post_single: false
}
K.widgets.shrinked = function(elem) {
  var context = elem
    , triggers = context.getElements(context.get('data-trigger'))
    , shouldPropagate = elem.get('data-shouldPropagate')
  triggers.addEvent('click', function(e) {
    if (!shouldPropagate) e.stop()
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
      if (typeof func == 'function') func(e)
    })
  })

    $(document.body).addEvents({
      'click:relay([data-tgt])': function(e){
        var tgt = e.target.get('data-tgt')
        var ev = e.target.get('data-event')
        var func
        if(tgt && (!ev || ev == 'click')){
          e.stop()
          func = K.tgt[tgt]
          if (typeof func == 'function') func.call(this, e.target)
        }
      }
    })

  // lightbox
  if($$('[rel=lightbox]').length > 0){
    new Asset.javascript('/javascripts/cerabox.js', {
      onload: function() {
        var box = new CeraBox({group: false});
        box.addItems('[rel=lightbox]', {
          fullSize: true,
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
      var link = el.get('href')
      function fn(){
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
      }
      var confirmMessage = el.get('data-doconfirm');
      if(confirmMessage){
        var msg = new Element('div', {'class':'box_confirm'})
        new Element('div', {'html':confirmMessage})
          .inject(msg)
        var box_bottom = new Element('div', {'class': 'box_bottom'})
          .inject(msg)
        new Element('a', {'class':'box_ok', 'html':'确定'})
          .addEvent('click', function(){
            fn.call()
            this.confirm_box.hide()
          }.bind(this)).inject(box_bottom)
        new Element('a', {'class':'box_cancel', 'html':'取消'})
          .addEvent('click', function(){
            this.confirm_box.hide()
          }.bind(this)).inject(box_bottom)
        this.confirm_box = new K.box(msg).show()
      }else{
        fn.call(this)
      }
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
      spinnerTarget: el.getParent(),
      onSuccess: function(responseTree, responseElements){
        var els = responseElements[0].getChildren()
        chat.empty()
        els.each(function(item){
            item.inject(chat)
        })
        K.set_max_height(chat.getElement('.c_content'))
        chat.getElement('.c_content').scrollTo(0, 9999)
        lock = false
        if(chat.getElement('[name=count]').value > 0){
          var replyCount = post.getElement('.reply')
          if (replyCount) replyCount.innerHTML = chat.getElement('[name=count]').value
        }
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

K.widgets.navigator = function(el){
  var nav_now = el.get('data-highlight')
  el.getElements('.z_'+nav_now).addClass('highlight')
  function open(){
    el.getElements('.menu').hide()
    this.getPrevious('.menu').setStyle('display', 'inline')
  }
  function close(){
    this.hide()
  }
  el.getElements('.tar').addEvents({
    'mouseenter': open,
    'click': open
  })
  el.getElements('.menu').addEvents({
    'mouseleave': close
  })
}

K.box = new Class({
  Implements: Options,
  options: {
    top: 200,
    width: 360,
    height: 150
  },
  initialize: function(msg, options){
    this.setOptions(options)
    this.box = new Element('div', {'class':'k_box'})
      .setStyles({
        'height': this.options.height,
        'width': this.options.width
      })
    this.box_top = new Element('div', {'class':'k_box_top'})
      .inject(this.box)
    this.close = new Element('div', {'class':'k_box_close'})
      .inject(this.box_top)
      .addEvent('click', function(){
        this.hide()
      }.bind(this))
    this.box_inner = new Element('div', {'class':'k_box_inner'})
      .inject(this.box)
    this.box_msg = new Element('div', {'class':'k_box_msg'})
      .inject(this.box_inner)
    msg.inject(this.box_msg)
  },
  show: function(){
    document.body.set('mask', {onClick: function(){
      this.hide()
    }.bind(this)}).mask()
    this.box.inject(document.body)
    var h = document.body.getScrollTop().toInt() + this.options.top
    var w = (document.body.clientWidth-this.box.getStyle('width').toInt())/2
    this.box.setStyles({
      'top': h,
      'left': w
    })
    return this
  },
  hide: function(){
    document.body.unmask()
    this.box.destroy()
    return this
  }
})
K.widgets.invite = function(el){
  el.addEvent('click', function(e){
    e.stop()
    var link = this.get('href')
    var msg = new Element('div', {'class':'box_invite'})
    new Element('div', {'html':'复制链接邀请好友'})
      .inject(msg)
    new Element('input', {'value':link})
      .addEvent('click', function(){
        this.select()
      }).inject(msg)
    new K.box(msg, {height:140, width: 420}).show()
  })
}

K.checkMobile = function(){
  K.log('checkMobile>>>')
  K.log('userAgent:'+navigator.userAgent)
  K.log('vendor:'+navigator.vendor)
  K.log('opera:'+window.opera)
  var a = navigator.userAgent||navigator.vendor||window.opera
  K.log('a:'+a)
  K.log('<<<checkMobile')
  return (/ucweb|mobile|android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))
}

K.widgets.expandAlbum = function(context) {
  context.addEvent('click', handler)
  function handler(e) {
    e.stop()
    context.removeEvent('click', handler)
    context.addClass('expanded_album')
    context.getElements('img').each(function(img) {
      var src = img.get("data-l")
      if (!src) return
      var desc = img.get("data-title")
      new Element('a', {
        href: img.get("data-o")
      , target: '_blank'
      }).wraps(
        img.set("src", src).grab(new Element('p', {text: desc}), 'after')
      )
    })
  }

}

})(document.id)

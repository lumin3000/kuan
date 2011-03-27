K.widgets.changeTag = function(el){
  el.addEvent('change', function(e){
    var item = $(this.options[this.selectedIndex])
    var v = item.get('data-tags')
    var textbox = $$('.tags')[0].textboxlist
    if(!v) return
    if(textbox.original.value != textbox.default_value) return
    $$('.tags')[0].textboxlist.reset(v)
  })
}

document.addEvent('domready', function(){
  K.post.init()
})

K.post = (function(){
  var photo_path = '/upload/photo'
  var init_title = function(){
    if(!$$('.new_title_starter')[0])return
    var s_new = $$('.new_title_starter')[0]
    var s_hide = $$('.hide_title_starter')[0]
    if($$('.title_text input')[0].value == ''){
      s_hide.hide()
      $$('.title_text')[0].hide()
      $$('.rich_editor_starter')[0].show()
      $$('.text_editor_starter')[0].hide()
    }else{
      s_new.hide()
      $$('.rich_editor_starter')[0].hide()
      $$('.text_editor_starter')[0].show()
    }
    s_new.addEvent('click', function(){
      $$('.title_text')[0].show()
      this.hide()
      s_hide.show()
      K.editor_toolbar.show($$('.text')[0])
      $$('.rich_editor_starter')[0].hide()
      $$('.text_editor_starter')[0].show()
      return false
    })
    s_hide.addEvent('click', function(){
      $$('.title_text')[0].hide()
      $$('.title_text input')[0].value = ''
      this.hide()
      s_new.show()
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
        K.photo_upload.spin(el)
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
          K.photo_upload.unspin(el)
        },
        failure: function(el, v){
          K.photo_upload.spin_error(el, v)
            //$$('.post_error')[0].innerHTML = v.message
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
    //var photos_list_sort
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
            box_file.hide()
            box_url.show()
            OverText.instances.each(function(item){
                item.reposition()
            })
        })
        tar_tog_local.addEvent('click', function(){
            box_file.show()
            box_url.hide()
        })
    }

  var init_editor = function(){
    if($$('.text')[0] && $$('.text')[0].hasClass('rich_text')){
      K.render_editor($('content'), {width:50, height:50})
    }
    if($('tar_tog_textarea')){
      init_toggle_textarea()
    }
    if($$('.rich_editor_starter')[0]){
      var s_rich = $$('.rich_editor_starter')[0]
      var s_text = $$('.text_editor_starter')[0]
      s_rich.addEvent('click', function(){
        this.hide()
        s_text.show()
        K.editor_toolbar.show($$('.text')[0])
        return false
      })
      s_text.addEvent('click', function(){
        this.hide()
        s_rich.show()
        K.editor_toolbar.hide($$('.text')[0])
        return false
      })
      setTimeout(function(){
        if($$('.title_text input')[0].value == ''){
          K.editor_toolbar.hide($$('.text')[0])
        }else{
          K.editor_toolbar.show($$('.text')[0])
        }
      }, 100)
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
          K.photo_upload.init()
          this.init_url_upload()
          init_toggle_upload()
        }
        this.before_submit()
      },
      before_submit: function(){
        var f = $('submit_btn').getParent('form')
        f.addEvent('submit', function(e){
          if($('photos_list') && $('photos_list').getElement('.loading')){
            e.stop()
            $$('.post_error')[0].set('html', '请图片上传完成后再提交')
            return
          }
          if(f.hasClass('loading')){
            e.stop()
            return
          }
          f.addClass('loading')
        })
      },
      url_upload: function(){
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
      },
      init_url_upload: function(){
        new OverText($('url_uploader_url'))
        $('url_uploader_btn') && $('url_uploader_btn').addEvent('click', this.url_upload)
      }
    }
})()


K.photo_upload = {
  getTemplate: function(){
    var tmpl = $('photo_template').value;
    tmpl = tmpl.replace(/&apos;/gm, '"');
    return Elements.from(tmpl)[0].clone()
  },
  spin: function(el){
    el.addClass('loading')
    var msg = new Element('span')
    new Element('span', {'html': '上传中...'}).inject(msg)
    new Element('a', { href: '#', 'html':'取消' })
      .addEvent('click', function(){
        el.unspin()
        el.destroy()
      }).inject(msg)
    el.set('spinner', {message: msg})
    el.spin()
  },
  unspin: function(el){
    el.removeClass('loading')
    el.unspin()
  },
  spin_error: function(el, v){
    if (!el || !el.get('spinner'))return
    el.get('spinner').msg.getElement('span')
      .setStyle('color', 'red')
      .set('html', v.message)
  },
  init: function(ty){
    var tar_single = $('tar_single_upload')
    var tar_multi = $('tar_multi_upload')
    //ty = ty || 'flash'
    var tmp = $$('.file_image .img_left')[0]
    tmp && tmp.getElement('.swiff-uploader-box') && tmp.getElement('.swiff-uploader-box').destroy()

    if(!($('image_uploader') || $$('input[name=file]')[0]) || !$('photo_template'))return

    var flash_flag = !(Browser.Plugins.Flash.version < 9);
    if(ty){
    }else if(typeof FormData != 'undefined'){
      ty = 'html5'
    }else if(Browser.Plugins.Flash && Browser.Plugins.Flash.version >= 9){
      ty = 'flash'
    }else{
      ty = 'iframe'
    }
    if(ty == 'html5'){
      tar_single.setStyle('display', 'inline')
      tar_multi.hide()
      K.photo_upload.html5()
    }else if(ty == 'flash'){
      tar_single.setStyle('display', 'inline')
      tar_multi.hide()
      K.photo_upload.flash()
    }else if(ty == 'iframe'){
      tar_single.hide()
      if(typeof FormData != 'undefined' || (Browser.Plugins.Flash && Browser.Plugins.Flash.version >= 9)){
        tar_multi.setStyle('display', 'inline')
      }else{
        tar_multi.hide()
      }
      K.photo_upload.iframe()
    }
  }
}

K.photo_upload.iframe = function(){
  var el
  new K.file_uploader($('image_uploader') || $$('input[name=file]')[0], '/upload/photo', {
    'multiple': false,
    'onStart': function(){
      var el = K.photo_upload.getTemplate()
      el.getElement('[name=tar_img]').set('src', '/images/default_photo.jpg')
      el.inject($('photos_list'))
      el.getElement('.the_close').addEvent('click', function(){
        var photo_item = this.getParent('[name=photo_item]')
        photo_item.destroy()
      })
      photos_list_sort.addItems(el)
      K.photo_upload.spin(el)
      return el
    },
    'onSuccess': function(v, el){
      if(v.status == 'error'){
        this.failure.call(this, v, el)
        return
      }
      el.getElement('.the_image a')
        .set('href', v.image.original)
      el.getElement('[name=tar_img]')
        .set('src', v.image.small)
      el.getElement('.the_text input')
        .show()
      el.getElement('.image_id')
        .set('value', v.image.id)
      el.getElement('[name=tar_process]').hide()
      K.photo_upload.unspin(el)
    },
    'onFailure': function(v, el){
      K.photo_upload.spin_error(el, v)
    }
  })
}
K.photo_upload.html5 = function(){
  var el
  new K.file_uploader($('image_uploader') || $$('input[name=file]')[0], '/upload/photo', {
    'multiple': true,
    'onStart': function(){
      var el = K.photo_upload.getTemplate()
      el.getElement('[name=tar_img]').set('src', '/images/default_photo.jpg')
      el.inject($('photos_list'))
      el.getElement('.the_close').addEvent('click', function(){
        var photo_item = this.getParent('[name=photo_item]')
        photo_item.destroy()
      })
      photos_list_sort.addItems(el)
      K.photo_upload.spin(el)
      return el
    },
    'onSuccess': function(v, el){
      if(v.status == 'error'){
        this.failure.call(this, v, el)
        return
      }
      el.getElement('.the_image a')
        .set('href', v.image.original)
      el.getElement('[name=tar_img]')
        .set('src', v.image.small)
      el.getElement('.the_text input')
        .show()
      el.getElement('.image_id')
        .set('value', v.image.id)
      K.photo_upload.unspin(el)
    },
    'onFailure': function(v, el){
      K.photo_upload.spin_error(el, v)
    }
  })
}
K.photo_upload.flash = function(){
  var el = $('image_uploader') || $$('input[name=file]')[0]
  new FancyUpload3.Attach('photos_list', el, {
    path: '/javascripts/Swiff.Uploader.swf',
    url: '/upload/photo',
    timeLimit:4*60,
    appendCookieData:true,
    fileSizeMax: 4 * 1024 * 1024,
    //fileListMax: 3,
    fieldName:'file',
    queued: true,
    verbose: true,
    zIndex: 0,
    //multiple: false,
    typeFilter: {
      'Images (*.jpg, *.jpeg, *.gif, *.png)': '*.jpg; *.jpeg; *.gif; *.png'
    },
    container:el.getParent(),
    onSelectFail: function(files) {
      files.each(function(file) {
	new Element('div', {
	  'class': 'file-invalid',
	  events: {
	    click: function() {
	      this.destroy();
	    }
	  }
	}).adopt(
	  new Element('span', {'html': file.validationErrorMessage || file.validationError})
	).inject(this.list, 'bottom');
      }, this);	
    },
    onSelectSuccess: function(files) {
    },
    onFileSuccess: function(file) {
      K.upload_log('/upload/photo : success : flash')
      var v = JSON.decode(file.response.text)
      if(!v || v.status != 'success'){
        alert('上传失败');
        file.remove();
        return;
      }
      file.ui.element.hide()
      file.ui.el.getElement('.the_text input').show()
      file.ui.el.getElement('.the_image a')
        .set('href', v.image.original)
      file.ui.el.getElement('[name=tar_img]')
        .set('src', v.image.small)
      file.ui.el.getElement('.image_id')
        .set('value', v.image.id)
    },
    onFileError: function(file) {
      var st = file.ui.el.getElement('.file')
      new Element('span', {
//	'html': file.errorMessage,
        'html': '上传失败',
	'class': 'file-error'
      }).inject(st);
      new Element('a', {'class': 'file-retry', 'html': '重试'}).inject(st).addEvent('click', function() {
	file.requeue();
        this.getParent().getElement('.file-error').destroy()
        this.destroy()
	return false;
      });
    },
    onFileRequeue: function(file) {
      this.start();
    }
    
  });
}

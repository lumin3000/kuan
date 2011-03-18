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
	    var flash_flag = !(Browser.Plugins.Flash.version < 9);
	    if(!Browser.Plugins.Flash ||Browser.Plugins.Flash.version < 9){
              init_upload()
	    }else{
              $('image_uploader') && K.multi_upload()
            }
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

ev = {
  el: null,
  create: function(){
    var tmpl = $('photo_template').value;
    tmpl = tmpl.replace(/&apos;/gm, '"');
    photo_item_template = Elements.from(tmpl)[0]
    el = photo_item_template.clone()
    el.inject($('photos_list'))
    el.set('spinner', {message: '<span>开始上传</span><a href="#">取消</a>'}).spin()
    el.get('spinner').msg.getElement('a').addEvent('click', function(){
      this.cancel()
    })
    return el
  },
  process: function(n){
    el.get('spinner').msg.getElement('span').set('html', n)
  },
  success: function(v){
    el.getElement('.the_image a')
      .set('href', v.image.original)
    el.getElement('[name=tar_img]')
      .set('src', v.image.small)
    el.getElement('.image_id')
      .set('value', v.image.id)

    el.unspin()
  },
  error: function(){
    el.get('spinner').msg.getElement('span').set('html', '上传失败')
  },
  cancel: function(){
    el.unspin()
    el.destroy()
    ///////xx.remove() ////////////////!!!!!!!!!!!!!!!
  }
}
K.multi_upload = function(){
	new FancyUpload3.Attach('photos_list', '#image_uploader', {
		path: '/javascripts/Swiff.Uploader.swf',
		url: '/upload/photo',
		timeLimit:4*60,
		appendCookieData:true,
		fileSizeMax: 4 * 1024 * 1024,
		fieldName:'file',
		verbose: true,
		zIndex: 0,
		//multiple: false,
		typeFilter: {
			'Images (*.jpg, *.jpeg, *.gif, *.png)': '*.jpg; *.jpeg; *.gif; *.png'
		},
		container:$('image_uploader').getParent(),
	  onSelectSuccess: function(files) {
	  },
	  onFileSuccess: function(file) {
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
            /*
	    file.ui.cancel.set('html', '重试').removeEvents().addEvent('click', function() {
	      file.requeue();
	      return false;
	    });*/
	    new Element('span', {
	      'html': file.errorMessage,
	      'class': 'file-error'
	    }).inject(file.ui.st);
	  },
	  onFileRequeue: function(file) {
            console.log('queue')
            /*
	    file.ui.cancel.set('html', '取消').removeEvents().addEvent('click', function() {
	      file.remove();
	      return false;
	    });*/
            
	    this.start();
	  }
          
	});
}

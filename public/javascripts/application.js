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

K.file_uploader = new Class({
    Implements: [Options],
    
    options: {
        /*
        onStart: nil,
        onCancel: nil,
        onSuccess: nil,
        onFailure: nil
        */
        tar: null
    },
    
    initialize: function(el, path, options){
        this.file = $(el);
        this.path = path
        if(!this.file){
            throw new Error('Can not find file element');
        }
        if(!path){
            throw new Error('Path is empty');
        }

        this.setOptions(options);
        var tar = $(this.options.tar);
        if(tar == null){
            this.file_box = new Element('div', {
            }).setStyles({
                'display':'inline'
            }).inject(this.file, 'before');
            this.file.inject(this.file_box);
        }else{
            /*
            tar = new Element('a', {
                'html':'上传',
                'href':'#'
            });*/
            var tar_size = tar.getComputedSize();
            
            this.file_box_outer = new Element('div', {
            }).inject(this.file, 'before').setStyles({
                'height':30,
                'width':120,
                'display':'inline'
            });
            
            this.file_box = new Element('span', {
            }).inject(this.file_box_outer).setStyles({
                'overflow':'hidden',
                'position':'absolute',
                'height':tar_size.totalHeight,
                'width':tar_size.totalWidth,
                'font-size':12
            });
            this.file.setStyles({
                'position':'absolute',
                'z-index':'100',
                'margin-left':'-180px',
                'font-size':30,
                'margin-top':'-5px',
                'opacity':0,
                'filter':'alpha(opacity=0)',
                'visibility':'visible'
            }).inject(this.file_box);
            tar.inject(this.file_box);
        }
        this.file_clone = this.file.clone();
        this.file.destroy();
        this.build_file();
        this.file.set('disabled', false);
    },
    build_file: function(){
        this.file = this.file_clone.inject(this.file_box, 'top')
            .set('disabled', true);
        this.file_clone = this.file_clone.clone();
        this.file.addEvents({
            'change': function(){
                this.start();
            }.bind(this),
            'mouseenter': function(){
                //this.file_box.getElement('a').fireEvent('mouseover');
            },
            'mouseleave': function(){
                //this.file_box.getElement('a').fireEvent('mouseleave');
            }
        });
    },
    start: function(){
        K.log('start')
        if(this.file.get('disabled') == true || this.file.value == ''){
            return false;
        }
        var f_tar = '_fff_'+Number.random(1,9999);
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
        }).inject(document.body).hide();
        this.file.inject(this.form);        
        this.build_file();
        setTimeout(function(){
            this.frame.addEvent('load', function(){
                this.complete();
            }.bind(this));
            this.form.submit();
        }.bind(this), 50);
        this.options.onStart &&
            this.options.onStart();
    },
    cancel: function(){
        K.log('cancel')
    },
    complete: function(){
        K.log('complete')
        function on_success(v){
            cb && cb(v);
        }
        function on_error(){
        }
        var v = this.frame.contentWindow.document.body.innerHTML;
        v = JSON.decode(v);
        this.success.call(this, v);
        this.form.destroy();
        document.body.removeChild(this.frame);
        this.file.set('disabled', false);
    },
    success: function(v){
        K.log('success')
        this.options.onSuccess &&
            this.options.onSuccess(v);
    }
});

K.editor = null;
K.render_editor = function(el){
    var textarea = $(el);
    var w  = textarea.getStyle('width').toInt() + 15;
    var h  = textarea.getStyle('height').toInt() - 50;
    K.editor = new MooEditable(textarea, {
        'actions':'toggleview | bold italic underline strikethrough | createlink unlink | urlimage ',
        'dimensions':{x:w,y:h}
    });
}

K.blog  = (function(){
    
    return {
        init_upload_icon: function(){
            new K.file_uploader($('image_uploader'), '/upload/blog_icon', {
                'onStart': function(){
                    $('blog_icon_feed').innerHTML = '上传中,请稍候...';
                },
                'onSuccess': function(v){
                    $('blog_icon_feed').innerHTML = '上传成功';
                    $('blog_icon_id').value = v.image.id; 
                    $('blog_icon_img').set('src', v.image.medium); 
                }
            });
        }
    };
})();

K.post = (function(){
    var photo_path = '/upload/photo';
    var init_title = function(){
        $$('.new_title_starter').addEvent('click', function(){
            $$('.title_text')[0].show();
            this.hide();
            return false;
        })
    };

    var photo_item_template;
    var photo_item = {
        create: function(){
            var el = photo_item_template.clone();
            el.getElement('[name=tar_img]').set('src', '/images/default_photo.jpg');
            el.inject($('photos_list'));
            this.process(el);
            photo_item.attach(el);
            photos_list_sort.addItems(el);
            el.getElement('.the_text input').hide();
            return el;
        },
        process: function(el){
        },
        success: function(el, v){
            el.getElement('.the_image a')
                .set('href', v.image.original);
            el.getElement('[name=tar_img]')
                .set('src', v.image.small);
            el.getElement('.the_text input')
                .show();
            el.getElement('.image_id')
                .set('value', v.image.id);
            el.getElement('[name=tar_process]').hide();
        },
        failure: function(el, v){
            $$('.post_error')[0].innerHTML = v.message;
            el.distroy();
        },
        attach: function(el){
            el.getElement('.the_close').addEvent('click', function(){
                var photo_item = this.getParent('[name=photo_item]');
                /*
                if(photo_item.getElement(['[name=tar_process]']) && photo_item.getElement(['[name=tar_process]']).isDisplayed()){
                }*/
                photo_item.destroy();
            });
        }
    };
    var init_upload = function(){
        var el;
        new K.file_uploader($('image_uploader'), photo_path, {
            'onStart': function(){
                el = photo_item.create();
            },
            'onSuccess': function(v){
                photo_item.success(el, v);
            }
        });
    };
    var photos_list_sort;
    var init_photo_items = function(){
        photos_list_sort = new Sortables($('photos_list'), {
            handle:'.the_drag_handle',
            clone:true
        });
        $$('[name=photo_item]').each(function(item){
            photos_list_sort.addItems(item);
        });
        $$('[name=photo_item]').each(function(item){
            photo_item.attach(item);
        });
    };

    var init_toggle_upload = function(){
        var tar_tog_url = $('tar_tog_url');
        var tar_tog_local = $('tar_tog_local');
        var box_file = $('box_file');
        var box_url = $('box_url');
        tar_tog_url.addEvent('click', function(){
            tar_tog_url.hide();
            tar_tog_local.show();
            box_file.hide();
            box_url.show();
            OverText.instances.each(function(item){
                item.reposition();
            });
        });
        tar_tog_local.addEvent('click', function(){
            tar_tog_url.show();
            tar_tog_local.hide();
            box_file.show();
            box_url.hide();
        });
    };

    var init_editor = function(){
        if($$('.text')[0] && $$('.text')[0].hasClass('rich_text')){
            K.render_editor($('content'));
        }
        $$('.rich_editor_starter').addEvent('click', function(){
            this.hide();
            K.render_editor($('content'));
            return false;
        });
        if($('tar_tog_textarea')){
            init_toggle_textarea();
        }
    };

    var init_toggle_textarea = function(){
        var tar_tog_textarea = $('tar_tog_textarea');
        var tar_tog_textarea_close = $('tar_tog_textarea_close');
        var box_text = $('box_text');
        if(box_text.isDisplayed()){
            tar_tog_textarea.hide();
            tar_tog_textarea_close.show();
        }
        tar_tog_textarea.addEvent('click', function(){
            tar_tog_textarea.hide();
            tar_tog_textarea_close.show();
            box_text.show();
            return false;
        });
        tar_tog_textarea_close.addEvent('click', function(){
            tar_tog_textarea.show();
            tar_tog_textarea_close.hide();
            box_text.hide();
            K.editor.setContent('');
            return false;
        });
    };
    return {
        init: function(){
            init_title();
            init_editor();
            
            if($('photos_list')){
                photo_item_template = Elements.from($('photo_template').value)[0];
                init_photo_items();
                if($('image_uploader') && $('photo_template')){
                    init_upload();
                }
                this.init_url_upload();
                init_toggle_upload();
            }
        },
        init_url_upload: function(){
            new OverText($('url_uploader_url'));
            $('url_uploader_btn') && $('url_uploader_btn').addEvent('click', function(){
                var url = $('url_uploader_url').value;
                var el = photo_item.create();
                photo_item.attach(el);
                new Request.JSON({
                    url: photo_path,
                    method: 'post',
                    data: {'url':url},
                    onComplete: function(result){
                        if(result.status == 'error'){
                            photo_item.failure(el, result);
                        }else{
                            $('url_uploader_url').value = '';
                            OverText.instances.each(function(item){
                                item.reposition();
                            });
                            photo_item.success(el, result);
                        }
                    }
                }).send();

            });
        }
    };
})();

K.posts = (function(){
    var init_flash = function(path, el){
        K.log('init_flash');
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
        });
    };
    var init_video = function(){
        $$('.video_tar_open').addEvent('click', function(){
            var p = this.getParent('.post');
            p.getElement('.video_thumb').hide();
            p.getElement('.video_full').show();
            if(!p.getElement('object')){
                init_flash(
                    p.getElement('.video_tar_open').get('href'), 
                    p.getElement('.video_player')
                );
            }
            return false;
        })
        $$('.video_tar_close').addEvent('click', function(){
            var p = this.getParent('.post');
            p.getElement('.video_thumb').show();
            p.getElement('.video_full').hide();
        })
    };

    return {
        init: function(){
            init_video();
        }
    };
})();

K.widgets = {}
K.widgets.shrinked = function(elem) {
  var context = elem
    , triggers = context.getElements(context.get('data-trigger'))
  triggers.addEvent('click', function(e) {
    e.stop()
    context.toggleClass('shrinked')
  })
}

K.widgets.fixHover = (function() {
  var events = {
        mouseenter: toggle
      , mouseleave: toggle
      }
  return function(elem) { elem.addEvents(events) }
  function toggle() {
    $(this).toggleClass('hover')
  }
})()

document.addEvent('domready', function(){
  var KEY = 'data-widget'
  $$('[' + KEY + ']').each(function(e){
    var type = e.get(KEY)
      , func = K.widgets[type]
    func && func(e)
  })
})

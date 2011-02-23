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
            tar = new Element('a', {
                'html':'上传',
                'href':'#'
            });
        }
        var tar_size = tar.getComputedSize();
        this.file_box_outer = new Element('div', {
        }).inject(this.file, 'before').setStyles({
            'height':30,
            'width':120
            //not working
            //'height':tar_size.totalHeight, 
            //'width':tar_size.totalWidth
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

K.render_editor = function(el){
    var textarea = $(el);
    var w  = textarea.getStyle('width').toInt();
    var h  = textarea.getStyle('height').toInt() - 50;
    new MooEditable(textarea, {
        'actions':'toggleview | bold italic underline strikethrough | createlink unlink | urlimage ',
        'dimensions':{x:w,y:h}
    });
}

K.post = (function(){
    var photo_path = '/upload/photo';
    var init_title = function(){
        $$('.new_title_starter').addEvent('click', function(){
            $$('.title_text')[0].show();
            this.hide();
            return false;
        })
    };

    var init_editor = function(){
        $$('.rich_editor_starter').addEvent('click', function(){
            this.hide();
            K.render_editor($('content'));
            return false;
        });
    };

    var photo_item_template;
    var photo_item = {
        create: function(){
            var el = photo_item_template.clone();
            el.inject($('photos_list'));
            this.process(el);
            photo_item.attach(el);
            return el;
        },
        process: function(el){
            el.getElement('[name=tar_img_a]').hide();
            el.getElement('[name=tar_desc]').hide();
        },
        success: function(el, v){
            el.getElement('[name=tar_img_a]')
                .set('href', v.image.original)
                .show();
            el.getElement('[name=tar_img]')
                .set('src', v.image.small);
            el.getElement('[name=tar_desc]')
                .show();
            el.getElement('.image_id')
                .set('value', v.image.id);
            el.getElement('[name=tar_process]').hide();
        },
        attach: function(el){
            el.getElement('[name=tar_close]').addEvent('click', function(){
                var photo_item = this.getParent('[name=photo_item]');
                if(photo_item.getElement(['[name=tar_process]']) && photo_item.getElement(['[name=tar_process]']).isVisible()){
                }
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
            handle:'[name=photo_item]',
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
        tar_tog_url.addEvent('click', function(){
            tar_tog_url.hide();
            tar_tog_local.show();
        });
        tar_tog_local.addEvent('click', function(){
            tar_tog_url.show();
            tar_tog_local.hide();
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
                        photo_item.success(el, result);
                    }
                }).send();

            });
        }
    };
})();

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

    var init_upload = function(){
        var tmpl = $('photo_template');
        new K.file_uploader($('image_uploader'), '/upload/photo', {
            'onSuccess': function(v){
                var val = tmpl.value.substitute({
                    'image_a': v.original,
                    'image': v.small,
                    'desc': '',
                    'id': v.id
                });
                new Element('div', {'html':val}).inject($('pics_ul'));
            }
        });
    };

    return {
        init: function(){
            init_title();
            init_editor();
            if($('image_uploader') && $('photo_template')){
                init_upload();
            }
        }
    };
})();

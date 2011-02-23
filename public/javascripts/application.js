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

K.remote_file = function(id, path, cb){
    var file = $(id);
    if(!file){
        throw new Error('Can not find file element');
    }
    if(!path){
        throw new Error('Path is empty');
    }
    var file_tmp = 'file_upload';
    var file_box = new Element('span', {
        'html': '<a href="#">上传文件:)</a><br />'
    }).inject(file, 'before').setStyles({
        'overflow':'hidden',
        'position':'absolute',
        'font-size':12
    });
    file.setStyles({
        'position':'absolute',
        'z-index':'100',
        'margin-left':'-180px',
        'font-size':30,
        'margin-top':'-5px',
        'opacity':0,
        'filter':'alpha(opacity=0)',
        'visibility':'visible'
    }).inject(file_box, 'top');
    var file_clone = file.clone();
    var file_feed = new Element('span', {
        'id': file_tmp,
        'html': '上传新文件'
    }).inject(file_box, 'after').setStyles({
        'margin-left':100
    });
    function file_event(){
        if(this.get('disabled') == true || file.value == ''){
            return false;
        }
        var f_tar = '_fff_'+Number.random(1,9999);
        var fr = new Element('iframe', {'id': f_tar, 'name': f_tar}).
            inject(document.body).
            setStyles({
                'position': 'absolute',
                'top': '-1000px',
                'left': '-1000px'
            })

        var f = new Element('form', {
            'action': path,
            'accept-charset': 'UTF-8',
            'enctype': 'multipart/form-data',
            'encoding': 'multipart/form-data', 
            'method': 'post',
            'target': f_tar
        }).inject(document.body).setStyle('display', 'none');
        file.inject(f);        
        file_feed.set('html', '开始上传');
        file = file_clone.inject(file_box, 'top')
            .set('disabled', true);
        bind_event(file);
        file_clone = file_clone.clone();
        function frame_loaded(e){
            var that = this;
            if(false){
                return;
            }
            function on_success(v){
                file_feed.set('html', '继续上传');
                cb && cb(v);
            }
            function on_error(){
            }
            var v = that.contentWindow.document.body.innerHTML;
            v = JSON.decode(v);
            on_success(v);
            document.body.removeChild(f);
            document.body.removeChild(fr);
            file.set('disabled', false);
        }
        setTimeout(function(){
            fr.addEvent('load', frame_loaded);
            f.submit();
        }, 50);
    }
    function bind_event(f){
        f.addEvents({
            'change': file_event,
            'mouseenter': function(){
                //file_box.getElement('a').fireEvent('mouseover');
            },
            'mouseleave': function(){
                //file_box.getElement('a').fireEvent('mouseleave');
            }
        });
    }
    bind_event(file);
}

K.init_editor = function(el, target){
    var textarea = $(el);
    if($(target)){
        $(target).destroy();
    }
    var w  = textarea.getStyle('width').toInt();
    var h  = textarea.getStyle('height').toInt() - 50;
    new MooEditable(textarea, {
        'actions':'toggleview | bold italic underline strikethrough | createlink unlink | urlimage ',
        'dimensions':{x:w,y:h}
    });
}

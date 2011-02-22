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
    function frame_loaded(){
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
        
        file.set('disabled', false);
        //file_submit.set('disabled', false);
    }
    var file_tmp = 'file_upload';
    var f_tar = '_fff_'+Number.random(1,9999);
    var fr = new Element('iframe', {'id': f_tar, 'name': f_tar}).
        inject(document.body, 'after').
        setStyles({
            'position': 'absolute',
            'top': '-1000px',
            'left': '-1000px'
        })
    setTimeout(function(){
        fr.addEvent('load', frame_loaded);
    }, 50);
    var file_btn = new Element('input', {
        'type': 'button',
        'value': '上传文件:)'
    }).inject(file, 'before').setStyles({
        'font-size':12,
        'overflow':'hidden',
        'position':'absolute'
    });
    var file_clone = file.clone();
    var file_feed = new Element('span', {
        'id': file_tmp,
        'html': '上传新文件'
    }).inject(file, 'after');
    /*var file_submit = new Element('input', {
        'type': 'submit', 'value': '上传'
    }).inject(file_feed, 'after')*/
    function file_event(){
        if(this.get('disabled') == true || file.value == ''){
            return false;
        }
        //this.set('disabled', true);
        var f = new Element('form', {
            'action': '/images',
            'accept-charset': 'UTF-8',
            'enctype': 'multipart/form-data',
            'encoding': 'multipart/form-data', 
            'method': 'post',
            'target': f_tar
        }).inject(document.body).setStyle('display', 'none');
        file.inject(f);        
        file_feed.set('html', '开始上传');
        file = file_clone.inject(file_feed, 'before').set('disabled', true).addEvent('change', file_event);
        file_clone = file_clone.clone();
        f.submit();
    }
    file.addEvent('change', file_event);
}

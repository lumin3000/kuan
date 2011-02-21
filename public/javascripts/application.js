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
    function frame_load(){
        var that = this;
        function on_success(){
            file_feed.set('html', '继续上传');
            var v = that.contentDocument.body.innerHTML;
            v = JSON.decode(v);
            cb && cb.bind(that)(v);
        }
        function on_error(){
        }
        on_success();
        
        file.set('disabled', false);
        file_submit.set('disabled', false);
    }
    var file_clone = file.clone();
    var file_tmp = 'file_upload';
    var f_tar = '_fff_'+Number.random(1,9999);
    var fr = new Element('iframe', {'id': f_tar, 'name': f_tar}).
        inject(document.body, 'after').
        setStyles({
            'position': 'absolute',
            'top': '-1000px',
            'left': '-1000px'
        }).addEvent('load', frame_load);
    var file_feed = new Element('span', {
        'id': file_tmp,
        'html': '上传新文件'
    }).inject(file, 'after');
    var file_submit = new Element('input', {
        'type': 'submit', 'value': '上传'
    }).inject(file_feed, 'after').addEvent('click', function(){
        if(this.get('disabled') == true || file.value == ''){
            return false;
        }
        this.set('disabled', true);
        var f = new Element('form', {
            'action': '/images',
            'enctype': 'multipart/form-data',
            'method': 'post',
            'target': f_tar
        }).inject(document.body).setStyle('display', 'none');
        file.inject(f);        
        file_feed.set('html', '开始上传');
        file = file_clone.inject(file_feed, 'before').set('disabled', true);
        file_clone = file_clone.clone();
        f.submit();
    });
}

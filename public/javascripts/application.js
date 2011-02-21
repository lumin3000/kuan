function remote_file(id, path, cb){
    var file = $(id);
    var f_id = '_fff';
    var fr = new Element('iframe', {'id': f_id}).
        inject(document.body, 'after').
        setStyles({
            'height': 60,
            'width': 360
        }).addEvent('load', frame_load);
    function frame_load(){
        cb && cb(this.contentDocument.body.innerHTML);
    }
    new Element('input', {
        'type': 'submit', 'value': '上传'
    }).inject(file, 'after').addEvent('click', function(){
        var f = new Element('form', {
            'action': '/images',
            'enctype': 'multipart/form-data',
            'method': 'post',
            'target': f_id
        }).inject(document.body);
        new Element('span', {
            'id': 'aaa',
            'html': '开始上传'
        }).inject(file, 'after');
        file.inject(f);        
        f.submit();
    });
}

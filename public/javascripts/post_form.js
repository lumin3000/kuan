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
  $('image_uploader') && K.multi_upload()
})

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
	var flash_flag = !(Browser.Plugins.Flash.version < 9); //是否支持flash
	if(!Browser.Plugins.Flash ||Browser.Plugins.Flash.version < 9){
          //使用K.file_uploader
	}
	new FancyUpload3.Attach('img_attach_list', '#image_uploader', {
		path: '/javascripts/Swiff.Uploader.swf',
		url: '/upload/photo',
		timeLimit:2*60,
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
              alert('a');
	    var result = JSON.decode(file.response.text)
            if(result.error){
              alert('上传失败');
              file.remove();
              return;
            }
            result = result.result;
	  },
	  onFileError: function(file) {
	    file.ui.cancel.set('html', '重试').removeEvents().addEvent('click', function() {
	      file.requeue();
	      return false;
	    });
	    new Element('span', {
	      'html': file.errorMessage,
	      'class': 'file-error'
	    }).inject(file.ui.cancel, 'after');
	  },
	  onFileRequeue: function(file) {
	    file.ui.cancel.set('html', '取消').removeEvents().addEvent('click', function() {
	      file.remove();
	      return false;
	    });
            
	    // this.start();
	  }
          
	});
}

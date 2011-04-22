MooEditable.UI.UploadImage = function(editor){
  var html = '输入图片链接 '
    + '<input type="text" class="dialog-url" value="" size="45" />'
    + '<input type="file" name="file" class="dialog-file" autocomplete="off" /><br />'
    + '<button class="dialog-button dialog-ok-button">' + MooEditable.Locale.get('ok') + '</button> '
    + '<button class="dialog-button dialog-cancel-button">' + MooEditable.Locale.get('cancel') + '</button>';

  return new MooEditable.UI.Dialog(html, {
    'class': 'mooeditable-uploadimage-dialog',
    onOpen: function(){
      var input = this.el.getElement('.dialog-url');
      var node = editor.selection.getNode();
      if (node.get('tag') == 'img'){
	this.el.getElement('.dialog-url').set('value', node.get('src'));
      };
      new K.file_uploader(this.el.getElement('.dialog-file'), '/upload/photo', {
        'multiple': false,
        'tar': new Element('a', {
          'html':'从本地上传',
          'href':'#'
        }).setStyles({
          'display':'block',
          'height':24,
          'width':100
        }),
        'onStart': function(){
          var msg = new Element('span')
          new Element('span', {'html': '上传中...'}).setStyle('padding-right', 6).inject(msg)
          new Element('a', { href: '#', 'html':'取消' })
            .addEvent('click', function(){
              this.el.unspin()
	      this.close();
            }.bind(this)).inject(msg)
          this.el.set('spinner', {message: msg})
          this.el.spin()
          if(Browser.ie){
            this.el.get('spinner').element.setStyle('width', '620')
            this.el.get('spinner').content.setStyle('width', '620')
            this.el.get('spinner').content.setStyle('text-align', 'center')
          }
        }.bind(this),
        'onSuccess': function(v){
          if(v.status == 'error'){
            alert('本地上传失败')
            return
          }
          input.value = 'http://img.kuandao.com' + v.image.large
          this.el.removeClass('loading')
          this.el.unspin()
          input.highlight()
        }.bind(this)
      });
      (function(){
	input.focus();
	input.select();
      }).delay(10);

    },
    onClick: function(e){
      if (e.target.tagName.toLowerCase() == 'button') e.preventDefault();
      var button = document.id(e.target);
      if (button.hasClass('dialog-cancel-button')){
	this.close();
      } else if (button.hasClass('dialog-ok-button')){
	this.close();
	var dialogAlignSelect = this.el.getElement('.dialog-align');
	var node = editor.selection.getNode();
	if (node.get('tag') == 'img'){
	  node.set('src', this.el.getElement('.dialog-url').get('value').trim());
	} else {
	  var div = new Element('div');
	  new Element('img', {
	    src: this.el.getElement('.dialog-url').get('value').trim()
	  }).inject(div);
	  editor.selection.insertContent(div.get('html'));
	}
      }
    }
  });
};
MooEditable.Actions.uploadimage = {
  title: '本地上传图片',
  dialogs: {
    prompt: function(editor){
      return MooEditable.UI.UploadImage(editor);
    }
  },
  command: function(){
    this.dialogs.uploadimage.prompt.open();
  }
};

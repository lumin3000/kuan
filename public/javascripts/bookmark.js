// 取图
var arr = imgFilter(document.getElementsByTagName('img'));
var img_urls = '[';
for(var i=0,l=arr.length; i<l; i++){
  img_urls += '"'+arr[i].src+'"'+(i==l-1?'':',');
}
img_urls += ']';
// 过滤图片
function imgFilter(arr){
  var new_arr = [];
  var tmp;
  for(var i=0,l=arr.length; i<l; i++){
    tmp = arr[i];
    if(tmp.width<100 || tmp.height<100){
      continue;
    }
    if(tmp.parentNode.rel == 'lightbox' && tmp.parentNode.href){
      tmp.src = tmp.parentNode.href
    }
    new_arr.push(tmp);
  }
  return new_arr;
}

// 选中的处理方式 ie与ff不同
var selValue = '';
if(document.selection && document.selection.createRange){
  selValue = document.selection.createRange().htmlText || '';
}else if(document.getSelection){
  selValue = document.getSelection();
}

var _default
if(selValue != ''){
  _default = 'text'
}else if(arr.length > 0){
  _default = 'pics'
}else{
  _default = 'link'
}
var _form = document.createElement('form');
_form.method = 'post';
_form.action = 'http://www.kuandao.com/posts/fetch/'+_default;
if(isNewWindow){
  _form.target = 'kuandao';
}

var _title = document.createElement('input')
_title.type = 'hidden'
_title.name = 'title'
_title.value = document.title
var _url = document.createElement('input')
_title.type = 'hidden'
_url.name = 'url'
_url.value = document.URL
var _content = document.createElement('input')
_title.type = 'hidden'
_content.name = 'content'
_content.value = selValue
var _imgs = document.createElement('input')
_title.type = 'hidden'
_imgs.name = 'imgs'
_imgs.value = img_urls

console.log(_content.value)

_form.appendChild(_title);
_form.appendChild(_url);
_form.appendChild(_content);
_form.appendChild(_imgs);
document.body.appendChild(_form);
_form.submit();

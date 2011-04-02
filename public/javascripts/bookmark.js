// 取图
var arr = imgFilter(document.getElementsByTagName('img'));
var img_urls = '[';
for(var i=0,l=arr.length; i<l; i++){
  img_urls += '"'+arr[i]+'"'+(i==l-1?'':',');
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
    if(tmp.parentNode.href && (tmp.parentNode.rel == 'lightbox' ||  /\.(jpg|jpeg|png|bmp|gif)$/i.test(tmp.parentNode.href))){
      new_arr.push(tmp.parentNode.href);
    }else{
      new_arr.push(tmp.src);
    }
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
var form = document.createElement('form');
form.method = 'post';
form.action = 'http://www.kuandao.com/posts/fetch/'+_default;
if(isNewWindow){
  form.target = 'kuandao';
}

var f_title = document.createElement('input')
f_title.type = 'hidden'
f_title.name = 'title'
f_title.value = document.title
var f_url = document.createElement('input')
f_url.type = 'hidden'
f_url.name = 'url'
f_url.value = document.URL
var f_content = document.createElement('input')
f_content.type = 'hidden'
f_content.name = 'content'
f_content.value = '<pre>'+selValue+'</pre>'
var f_imgs = document.createElement('input')
f_imgs.type = 'hidden'
f_imgs.name = 'imgs'
f_imgs.value = img_urls

form.appendChild(f_title);
form.appendChild(f_url);
form.appendChild(f_content);
form.appendChild(f_imgs);
document.body.appendChild(form);
form.submit();

K.wall = (function(){  
    var base_list;
    var columns = [];
    function create_column(){
        var el = new Element('div', {'class':'list'});
        var ul = new Element('ul').inject(el);
        new Element('div').inject(el);
        el.inject($$('.wall')[0]);
        columns.push({'el':el, 'ul':ul, 
                      'fx':new Fx.Scroll(el, {
                          duration: 1500,
                          transition:Fx.Transitions.Quad.easeInOut
                      })
                     });
    }
    function fetch(column){
        var el = base_list.getElements('li')[0];
        if(column.ul.getElement('li') && column.ul.getElement('li').hasClass('text')){
            el = base_list.getElement('li.pics');
            if(!el){
                el = base_list.getElement('li');
            }
        }
        return el;
    }
    function rec(column){
        var el = column.ul.getLast('li');
        if(base_list.getElements('li').length > 8){
            el.dispose();
            return;
        }
        if(el.hasClass('text')){
            el.set('class', 'text');
        }
        el.inject(base_list);
    }
    function ins(column, ntw){
        var el = fetch(column);
        if(!el){
            return;
        }
        var height = el.getSize().y;
        if(!el.getElement('img')){
            el.addClass('bg'+Number.random(1,12));
        }
        column.el.getLast('div').setStyle('height', height);
        column.el.setStyle('height', 'auto');
        column.el.setStyle('height', column.el.getSize().y);
        el.inject(column.ul, 'top');
        column.el.scrollTop = height;
        if(ntw){
            column.el.setStyle('height', 'auto');
        }else{
            //el.set('tween', {duration: 'long', transition:Fx.Transitions.Quad.easeInOut});
            //el.tween('height', height);
            column.fx.toTop();
        }
    }
    function get_columns_count(){
        return ((document.getSize().x-180)/180).floor().limit(1, 7);
    }

    return {
        init: function(){
            base_list = $$('.store ul')[0];
            var cls = get_columns_count(); 
            $$('.wall')[0].setStyle('width', cls*180);
            
            for(var i=0; i<cls; i++){
                create_column();
            }
            window.addEvent('resize', function(){
                if(columns.length != get_columns_count()){
                    window.removeEvents('resize');
                    location.href = location.href;
                }
            });
            
            var first_line_count = 6;
            for(var i=0;i<cls*first_line_count;i++){
                ins(columns[(i/first_line_count).floor()], true);
            }
            var inv = function(){
                setTimeout(function(){
                    K.wall.show_line();
                    if(base_list.getElements('.pics').length < 10){
                        K.wall.more();
                    }
                    inv();
                }, 20000);
            }
            inv();
            
        },
        more: function(){
            new Request.HTML({
                url: '/wall.html',
                append: $$('.store ul')[0],
                method: 'get',
                onComplete: function(){
                }
            }).send();
        },
        show: function(v){
            if(v === null){
                v = Number.random(0, columns.length-1);
            }
            var col = columns[v];

            if(col.ul.getElements('li').length > 6){
                rec(col);
            }
            ins(col);
        },
        show_line: function(){
            for(var i=0,l=columns.length;i<l;i++){
                if(Browser.ie){
                    setTimeout((function(j){return function(){K.wall.show(j);};})(i), 800*i);
                }else{
                    K.wall.show(i);
                }
            }
        }
    };
})();

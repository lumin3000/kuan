/**
 * @package		CeraBox
 * 
 * @author 		Sven
 * @since 		13-01-2011
 * @version 	1.2.11-r
 * 
 * This package requires MooTools 1.3.* + MooTools More Assets
 * 
 * @license The MIT License
 * 
 * Copyright (c) 2011-2012 Ceramedia, <http://ceramedia.nl/>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

var CeraBox = new Class({
	
	Implements: [Options],
	
	loaderTimer: null,
	timeOuter: null,
	
	vars : {
		items: new Array(),
		cerabox: null,
		windowOpen: false,
		busy: false,
		currentIndex: [0,0]
	},
	
	options: {
		group:					true,
		errorLoadingMessage:	'The requested content cannot be loaded. Please try again later.',
		events:					{
			onClose:	function(){},
			onOpen:		function(){},
			onChange:	function(){},
			_onClose:	null,
			_onOpen:	null,
			_onChange:	null
		}
	},
	
	//initialization
	initialize: function(options) {
		//set options
		this.setOptions(options);
		
		this.initHTML();
		
		if (Browser.ie6)
			$('cerabox-loading').addClass('ceraboxbox-ie6');
		
		window.addEvent('resize', this._resize.bind(this));
		
		$('cerabox-loading').addEvent('click', function(event){
			event.stop();
			this.close();
		}.bind(this));
		
		document.addEvent('keyup', function(event) {
			if (event.key == 'esc')
				this.close();
			if (event.target.get('tag')=='input' || event.target.get('tag')=='select' || event.target.get('tag')=='textarea')
				return;
			if (event.key == 'left')
				this.vars.cerabox.getElement('.cerabox-left').fireEvent('click', event);
			if (event.key == 'right')
				this.vars.cerabox.getElement('.cerabox-right').fireEvent('click', event);
		}.bind(this));
	},
	
	/**
	 * Add items to the box
	 * 
	 * @param mixed container
	 * @param object options {
	 * 		ajax:			{},
	 * 		group:			bool,
	 * 		width:			int,
	 * 		height:			int,
	 * 		displayTitle:	bool,
	 * 		fullSize:		bool,
	 * 		displayOverlay:	bool,
	 * 		clickToClose:	bool,
	 * 		animation:		'fade'|'ease',
	 * 		events:			{
	 * 			onOpen:			function(currentItem, collection){},
	 * 			onChange:		function(currentItem, collection){},
	 * 			onClose:		function(currentItem, collection){}
	 * 		}
	 * }
	 */
	addItems: function(container, options) {
		var items = $$(container);
		if (items.length<1)
			throw 'Empty container';
		
		var itemsIndex = this.vars.items.length;
		this.vars.items[itemsIndex] = [];
		
		options = options ? options : {};
		
		Array.each(items, function(item, index) {
			
			// Dont group selection
			if (options.group===false||(options.group!==true&&this.options.group===false)) {
				this.vars.items[itemsIndex] = [];
				this.vars.items[itemsIndex][0] = item;
				index 		= [itemsIndex,0];
				itemsIndex	= itemsIndex+1;
			}
			else {
				this.vars.items[itemsIndex][index] = item;
				index = [itemsIndex,index];
			}
			
			//this.vars.cerabox.getElement('.cerabox-left').removeEvents('click').setStyle('display','none');
			if (typeof options.ajax != 'undefined') {
				item.addEvent('click', function(event){
					event.preventDefault();
					if (this.vars.busy)
						return;
					this.vars.busy=true;
					// Add events
					this._addCallbacks((typeof options.events != 'undefined')?options.events:null);
					
					this.vars.cerabox.setStyle('cursor','auto').removeEvents('click');
					if (true===options.clickToClose)
						this.vars.cerabox.setStyle('cursor','pointer').addEvent('click', function(event){event.stop(); this.close();}.bind(this));
					this._showInit();
					this.showAjax(index, options);
				}.bind(this));
			}
                  else if (true){
			//else if (item.get('href').replace(/(\?.*)/,'').test(/\.jpg|jpeg|png|gif$/i)) {
				item.addEvent('click', function(event){
					event.preventDefault();
					if (this.vars.busy)
						return;
					this.vars.busy=true;
					// Add events
					this._addCallbacks((typeof options.events != 'undefined')?options.events:null);
					
					this.vars.cerabox.setStyle('cursor','auto').removeEvents('click');
					if (true===options.clickToClose)
						this.vars.cerabox.setStyle('cursor','pointer').addEvent('click', function(event){event.stop(); this.close();}.bind(this));
					this._showInit();
					this.showImage(index, options);
				}.bind(this));
			}
			else if (item.get('href').test(/\.swf$/i)) {
				item.addEvent('click', function(event){
					event.preventDefault();
					if (this.vars.busy)
						return;
					this.vars.busy=true;
					// Add events
					this._addCallbacks((typeof options.events != 'undefined')?options.events:null);
					
					this.vars.cerabox.setStyle('cursor','auto').removeEvents('click');
					if (true===options.clickToClose)
						this.vars.cerabox.setStyle('cursor','pointer').addEvent('click', function(event){event.stop(); this.close();}.bind(this));
					this._showInit();
					this.showSwf(index, options);
				}.bind(this));
			}
			else {
				item.addEvent('click', function(event){
					event.preventDefault();
					if (this.vars.busy)
						return;
					this.vars.busy=true;
					// Add events
					this._addCallbacks((typeof options.events != 'undefined')?options.events:null);
					
					this.vars.cerabox.setStyle('cursor','auto').removeEvents('click');
					if (true===options.clickToClose)
						this.vars.cerabox.setStyle('cursor','pointer').addEvent('click', function(event){event.stop(); this.close();}.bind(this));
					this._showInit();
					this.showIframe(index, options);
				}.bind(this));
			}
		}.bind(this));
	},
	
	/**
	 * Display AJAX item
	 * 
	 * @param array index
	 * @param object options
	 */
	showAjax: function(index, options) {
		//if (this.vars.busy)
			//return;
		
		var ceraBox = this;
		
		var items		= this.vars.items[index[0]];
		var currentItem	= items[index[1]];
		
		this.loaderTimer = this._displayLoader.delay(200, this);
		
		var requestEr = new Request.HTML({
			url: currentItem.get('href'),
			method: options.ajax.method?options.ajax.method:'post',
			data: options.ajax.data?options.ajax.data:'',
			
			onSuccess: function(responseTree) {
				if (false===ceraBox.vars.busy)
					return;
				
				clearInterval(ceraBox.loaderTimer);
				$('cerabox-loading').setStyle('display', 'none');
				
				if (false!==options.displayOverlay)
					ceraBox._displayOverlay();
				
				var ajaxEle = ceraBox.vars.cerabox.getElement('#cerabox-ajaxPreLoader').empty().adopt(responseTree);
				// Needed to know its size
				ceraBox.vars.cerabox.setStyle('display','block');
				
				ajaxEle.setStyle('width', options.width?options.width:ajaxEle.getScrollSize().x + 'px');
				ajaxEle.setStyle('height', options.height?options.height:ajaxEle.getScrollSize().y + 'px');
				
				var dimension = ceraBox._getSizeElement(ajaxEle, (true===options.fullSize?true:false));
				
				ajaxEle = ajaxEle.get('html');
				ceraBox.vars.cerabox.getElement('#cerabox-ajaxPreLoader').empty().setStyles({'width':0,'height':0});
				
				// Hide title
				ceraBox.vars.cerabox.getElement('.cerabox-title span')
					.setStyle('display','none')
					.empty();
				
				// If window open morph to new size
				if (ceraBox.vars.windowOpen==true) {
					ceraBox._transformItem(dimension.width, dimension.height);
				}	
				
				ceraBox.vars.cerabox.getElement('.cerabox-content').set('tween', {duration: 300}).tween('opacity','0')
					.get('tween')
					.addEvent('complete', function(){
						this.removeEvents('complete');
						
						if (false===ceraBox.vars.busy)
							return;
						
						if (false!==options.displayTitle)
							ceraBox.vars.cerabox.getElement('.cerabox-title span')
								.setStyle('display','block')
								.set('text',(items.length>1?'Item ' + (index[1]+1) + ' / ' + items.length + ' ':'') + (currentItem.get('title')?currentItem.get('title'):''));
						
						ceraBox.vars.cerabox.getElement('.cerabox-content')
							.empty()
							.set('opacity',0)
							.set('html', ajaxEle)
							.set('tween', {duration: 100}).tween('opacity','1');
						
						if (items.length>1)
							ceraBox._addNavButtons(index);
						
						ceraBox._openWindow(dimension.width, dimension.height, options.animation?options.animation:'fade', index);
						
						if (true===options.fullSize)
							ceraBox._resize();
						
						ceraBox.vars.busy = false;
					});
			},
			onTimeout: function() { ceraBox._timedOut(index, options); },
			onFailure: function() { ceraBox._timedOut(index, options); },
			onException: function() { ceraBox._timedOut(index, options); }
		}).send();
	},
	
	/**
	 * Display image item
	 * 
	 * @param array index
	 * @param object options
	 */
	showImage: function(index, options) {
		//if (this.vars.busy)
			//return;
		
		var ceraBox = this;
		
		var items		= this.vars.items[index[0]];
		var currentItem	= items[index[1]];
		
		this.loaderTimer = this._displayLoader.delay(200, this);
		
		var image = new Asset.image(currentItem.get('href'), {
			onload: function() {
				//ceraBox.vars.busy = true;
				
				if (false===ceraBox.vars.busy)
					return;
				
				clearInterval(ceraBox.loaderTimer);
				$('cerabox-loading').setStyle('display', 'none');
				
				if (false!==options.displayOverlay)
					ceraBox._displayOverlay();
				
				this.set('width', options.width?options.width:this.get('width'));
				this.set('height', options.height?options.height:this.get('height'));
				
				var dimension = ceraBox._getSizeElement(this, (true===options.fullSize?true:false));
				
				// Hide title
				ceraBox.vars.cerabox.getElement('.cerabox-title span')
					.setStyle('display','none')
					.empty();
				
				// If window open morph to new size
				if (ceraBox.vars.windowOpen==true) {
					ceraBox._transformItem(dimension.width, dimension.height);
				}
				
				ceraBox.vars.cerabox.getElement('.cerabox-content').set('tween', {duration: 300}).tween('opacity','0')
					.get('tween')
					.addEvent('complete', function(){
						this.removeEvents('complete');
						
						if (false===ceraBox.vars.busy)
							return;
						
						if (false!==options.displayTitle)
							ceraBox.vars.cerabox.getElement('.cerabox-title span')
								.setStyle('display','block')
								.set('text',(items.length>1?'Item ' + (index[1]+1) + ' / ' + items.length + ' ':'') + (currentItem.get('title')?currentItem.get('title'):''));
						
						ceraBox.vars.cerabox.getElement('.cerabox-content')
							.empty()
							.set('opacity',0)
							.adopt(image)
							.set('tween', {duration: 100}).tween('opacity','1');
						
						if (items.length>1)
							ceraBox._addNavButtons(index);
						
						ceraBox._openWindow(dimension.width, dimension.height, options.animation?options.animation:'fade', index);
						
						if (true===options.fullSize)
							ceraBox._resize();
						
						ceraBox.vars.busy = false;
                                          ceraBox.vars.cerabox.makeDraggable() //add by hsy
					});
			},
			onerror: function() {
				ceraBox._timedOut(index, options);
			}
		});
	},
	
	/**
	 * Display swf item
	 * 
	 * @param array index
	 * @param object options
	 */
	showSwf: function(index, options) {
		//if (this.vars.busy)
			//return;
		
		this.vars.busy = true;
		
		var ceraBox = this;
		
		var items		= this.vars.items[index[0]];
		var currentItem	= items[index[1]];
		
		// Hide title
		ceraBox.vars.cerabox.getElement('.cerabox-title span')
			.setStyle('display','none')
			.empty();
		
		var dimension = {width:options.width?options.width:500, height:options.height?options.height:400};
		
		var swfEr = new Swiff(currentItem.get('href'), {
			width: dimension.width,
		    height: dimension.height,
			params: {
				wMode: 'opaque'
		    }
		});
		
		if (false!==options.displayOverlay)
			ceraBox._displayOverlay();
		
		// If window open morph to new size
		if (ceraBox.vars.windowOpen==true) {
			ceraBox._transformItem(dimension.width, dimension.height);
		}
		
		ceraBox.vars.cerabox.getElement('.cerabox-content').set('tween', {duration: 300}).tween('opacity','0')
			.get('tween')
			.addEvent('complete', function(){
				this.removeEvents('complete');
				
				if (false===ceraBox.vars.busy)
					return;
				
				if (false!==options.displayTitle)
					ceraBox.vars.cerabox.getElement('.cerabox-title span')
						.setStyle('display','block')
						.set('text',(items.length>1?'Item ' + (index[1]+1) + ' / ' + items.length + ' ':'') + (currentItem.get('title')?currentItem.get('title'):''));
				
				ceraBox.vars.cerabox.getElement('.cerabox-content')
					.empty()
					.set('opacity',0)
					.adopt(swfEr)
					.set('tween', {duration: 100}).tween('opacity','1');
				
				if (items.length>1)
					ceraBox._addNavButtons(index);
				
				ceraBox._openWindow(dimension.width, dimension.height, options.animation?options.animation:'fade', index);
				
				if (true===options.fullSize)
					ceraBox._resize();
				
				ceraBox.vars.busy = false;
			});
	},
	
	/**
	 * Display iframe item
	 * 
	 * @param array index
	 * @param object options
	 */
	showIframe: function(index, options) {
		//if (this.vars.busy)
			//return;
		
		var ceraBox = this;
		
		var items		= this.vars.items[index[0]];
		var currentItem	= items[index[1]];
		
		this.loaderTimer = this._displayLoader.delay(200, this);
		// Set timeout timer incase request cannot be done
		this.timeOuter = this._timedOut.delay(10000, this, [index, options]);
		
		var ceraIframe = new IFrame({
			src: currentItem.get('href'),
			
			events: {
				load: function() {
					ceraBox.vars.busy = true;
					
					clearInterval(ceraBox.timeOuter);
					clearInterval(ceraBox.loaderTimer);
					$('cerabox-loading').setStyle('display', 'none');
					
					if (false!==options.displayOverlay)
						ceraBox._displayOverlay();
					
					this.setStyles({
						width: options.width?options.width:'1px',
						height: options.height?options.height:'1px',
						border: '0'
					});
					
					var dimension = ceraBox._getSizeElement(this, (true===options.fullSize?true:false));
					
					if (items.length>1)
						ceraBox._addNavButtons(index);
					
					// Hide title
					ceraBox.vars.cerabox.getElement('.cerabox-title span')
						.setStyle('display','none')
						.empty();
					
					// If window open morph to new size
					if (ceraBox.vars.windowOpen==true) {
						ceraBox._transformItem(dimension.width, dimension.height);
					}
					
					ceraBox._openWindow(dimension.width, dimension.height, options.animation?options.animation:'fade', index);
					
					if (true===options.fullSize)
						ceraBox._resize();
					
					ceraBox.vars.cerabox.getElement('.cerabox-content').set('tween', {duration: 100}).tween('opacity','1');
					
					ceraBox.vars.busy = false;
				}
			}
		});
		
		ceraIframe.set('border','0');
		ceraIframe.set('frameborder','0');
		
		// Open it so onload fires
		this.vars.cerabox.setStyle('display','block').getElement('.cerabox-content')
			.empty()
			.set('opacity',0)
			.adopt(ceraIframe);
	},
	
	/**
	 * Close box
	 */
	close: function() {
		//if (this.vars.busy)
			//return;
		
		this.vars.busy = true;

		clearInterval(this.timeOuter);
		clearInterval(this.loaderTimer);
		$('cerabox-loading').setStyle('display', 'none');
		
		var ceraBox = this;
		
		ceraBox.vars.cerabox.set('tween', {duration: 50}).tween('opacity', '0').get('tween')
			.addEvent('complete', function() {
				this.removeEvents('complete');
				
				this.element.setStyle('display','none');
				$('cerabox-background').set('tween', {duration: 150,link:'chain'}).tween('opacity','0').tween('display','none');
				
				ceraBox.vars.cerabox.getElement('.cerabox-content').empty();
				ceraBox.vars.cerabox.getElement('.cerabox-left').removeEvents('click').setStyle('display','none');
				ceraBox.vars.cerabox.getElement('.cerabox-right').removeEvents('click').setStyle('display','none');
				
				var collection	= ceraBox.vars.items[ceraBox.vars.currentIndex[0]];
				var currentItem = collection[ceraBox.vars.currentIndex[1]];
				
				if (ceraBox.vars.windowOpen){
					if (null!==ceraBox.options.events._onClose)
						ceraBox.options.events._onClose.call(ceraBox, currentItem, collection);
					else
						ceraBox.options.events.onClose.call(ceraBox, currentItem, collection);
				}
				
				ceraBox.vars.windowOpen = false;
				ceraBox.vars.busy = false;
			});
	},
	
	/**
	 * Inject needed HTML to the body
	 */
	initHTML: function() {
		var wrapper = $(document.body);
		
		wrapper.adopt([
				new Element('div',{'id':'cerabox-loading'}).adopt(new Element('div')),
				new Element('div',{'id':'cerabox-background', 'styles':{'height':wrapper.getScrollSize().y+'px'}, 'events':{'click':function(event){event.stop();this.close()}.bind(this)}}),
				this.vars.cerabox = new Element('div',{'id':'cerabox'}).adopt([
				                                    new Element('div', {'class':'cerabox-content'}),
				                                    new Element('div', {'class':'cerabox-title'}).adopt(new Element('span')),
				                                    new Element('a', {'class':'cerabox-close','events':{'click':function(event){event.stop();this.close()}.bind(this)}}),
				                                    new Element('a', {'class':'cerabox-left'}).adopt(new Element('span')),
				                                    new Element('a', {'class':'cerabox-right'}).adopt(new Element('span')),
				                                    new Element('div', {'id':'cerabox-ajaxPreLoader', 'styles':{'float':'left','overflow':'hidden','display':'block'}})
				])
		]);
	},
	
	/**
	 * Has timed out display error
	 * 
	 * @param array index
	 */
	_timedOut: function(index, options) {
				
		this.vars.busy = true;
		
		clearInterval(this.loaderTimer);
		$('cerabox-loading').setStyle('display', 'none');
		
		this._displayOverlay();
		
		this.vars.cerabox.getElement('.cerabox-title span')
			.setStyle('display','none')
			.empty();
		
		var ceraBox = this;
		
		var items = this.vars.items[index[0]];
		
		this.vars.cerabox.getElement('.cerabox-content').set('tween', {duration: 300}).tween('opacity','0')
			.get('tween')
			.addEvent('complete', function(){
				this.removeEvents('complete');
				
				if (false===ceraBox.vars.busy)
					return;
				
				ceraBox.vars.cerabox.getElement('.cerabox-content')
					.empty()
					.set('opacity',0)
					.adopt(new Element('span',{'text':ceraBox.options.errorLoadingMessage}))
					.set('tween', {duration: 100}).tween('opacity','1');
				
				if (items.length>1)
					ceraBox._addNavButtons(index);
				
				ceraBox._openWindow(250, 50, options.animation?options.animation:'fade', index);
				
				/*if (true===options.fullSize)
					ceraBox._resize();*/
				
				ceraBox.vars.busy = false;
			});
		
		
		// If window open morph to new size
		if (ceraBox.vars.windowOpen==true) {
			ceraBox._transformItem(250, 50);
		}
	},
	
	/**
	 * Add navigation buttons for group items
	 * 
	 * @param array index
	 */
	_addNavButtons: function(index) {
		var ceraBox = this;
		this.vars.cerabox.getElement('.cerabox-left').removeEvents('click').setStyle('display','none');
		this.vars.cerabox.getElement('.cerabox-right').removeEvents('click').setStyle('display','none');
		
		if (this.vars.items[index[0]][(index[1]-1)]) {
			this.vars.cerabox.getElement('.cerabox-left').setStyle('display','block').addEvent('click', function(event){
				
				event.stopPropagation();
				this.setStyle('display','none');
				ceraBox.vars.items[index[0]][(index[1]-1)].fireEvent('click', event);
			});
		}
		if (this.vars.items[index[0]][(index[1]+1)]) {
			this.vars.cerabox.getElement('.cerabox-right').setStyle('display','block').addEvent('click', clickFnc=function(event){
				
				event.stopPropagation();
				this.setStyle('display','none');
				ceraBox.vars.items[index[0]][(index[1]+1)].fireEvent('click', event);
			});
		}
	},
	
	/**
	 * Transform item to an other size
	 * 
	 * @param int width
	 * @param int height
	 * @return morph
	 */
	_transformItem: function(width, height) {
		var morphObject = {
			'display':'block',
			'width':width,
			'height':height,
			'opacity':1
		};
		if (window.getSize().x > this.vars.cerabox.getSize().x+40 && window.getSize().x > width+40) {
			this.vars.cerabox.setStyles({
				'left':'50%',
				'right':'auto'
			});
			morphObject['margin-left'] = ((-width/2)+$(document.body).getScroll().x) + 'px';
		}
		else {
			this.vars.cerabox.setStyles({
				'margin-left':'0',
				'left':'auto',
				'right':'20px'
			});
		}
		if (window.getSize().y > this.vars.cerabox.getSize().y+40 && window.getSize().y > height+40) {
			this.vars.cerabox.setStyles({
				'top':'50%'
			});
			morphObject['margin-top'] = ((-height/2)+$(document.body).getScroll().y) + 'px';
		}
		else {
			if (height+40 > ($(document.body).getScrollSize().y-$(document.body).getScroll().y)) {
				this.vars.cerabox.setStyles({
					'margin-top':'0',
					'top':($(document.body).getScrollSize().y-(height+60)>20?$(document.body).getScrollSize().y-(height+60):20) + 'px'
				});
			}
			else {
				this.vars.cerabox.setStyles({
					'margin-top':'0',
					'top':$(document.body).getScroll().y + 20 + 'px'
				});
			}
		}
		return this.vars.cerabox.set('morph', {duration: 150})
			.morph(morphObject).get('morph');
	},
	
	/**
	 * Initialize show function
	 */
	_showInit: function() {
		//if (this.vars.busy)
			//return;
		
		// Make sure it doesnt time out when started a new request and prev loader is gone
		clearInterval(this.timeOuter);
		clearInterval(this.loaderTimer);
		$('cerabox-loading').setStyle('display', 'none');
	},
	
	/**
	 * Open cerabox window
	 * 
	 * @param int width
	 * @param int height
	 * @param string[optional] animation 'ease'|'fade'
	 * @param array[optional] index item
	 */
	_openWindow: function(width, height, animation, index) {
		if (this.vars.cerabox.getElement('.cerabox-content iframe'))
			this.vars.cerabox.getElement('.cerabox-content iframe').setStyles({'width':width,'height':height});
		
		this.vars.currentIndex = index;
		var currentItem = this.vars.items[index[0]][index[1]];

		if (this.vars.windowOpen==true) {
			// onChange event
			if (null!==this.options.events._onChange)
				this.options.events._onChange.call(this, currentItem, this.vars.items[index[0]]);
			else
				this.options.events.onChange.call(this, currentItem, this.vars.items[index[0]]);
			return;
		}

		switch (animation) {
		case 'ease':	
			this.vars.cerabox.setStyles({
				'display':'block',
				'left':currentItem.getPosition().x + 'px',
				'top':currentItem.getPosition().y + 'px',
				'width':currentItem.getSize().x + 'px',
				'height':currentItem.getSize().y + 'px',
				'margin':0,
				'opacity':0
			}).set('morph', {duration: 200}).morph({
				'left':((window.getSize().x/2)) + 'px',
				'top':((window.getSize().y/2)) + 'px',
				'width':width,
				'height':height,
				'margin-left':((-width/2)+$(document.body).getScroll().x) + 'px',
				'margin-top':((-height/2)+$(document.body).getScroll().y) + 'px',
				'opacity':'1'
			});
			break;
		case 'fade':
		default:
			this.vars.cerabox.setStyles({
				'display':'block',
				'left':'50%',
				'top':'50%',
				'width':width,
				'height':height,
				'opacity':0,
				'margin-left':((-width/2)+$(document.body).getScroll().x) + 'px',
				'margin-top':((-height/2)+$(document.body).getScroll().y) + 'px'
			}).set('tween', {duration: 150}).tween('opacity', '1');
			break;
		}
		// onOpen event
		if (null!==this.options.events._onOpen)
			this.options.events._onOpen.call(this, currentItem, this.vars.items[index[0]]);
		else
			this.options.events.onOpen.call(this, currentItem, this.vars.items[index[0]]);
		
		currentItem.blur();
		this.vars.windowOpen = true;
	},
	
	/**
	 * Display transparen overlay
	 */
	_displayOverlay: function() {
		$('cerabox-background').setStyles({'display':'block','opacity':'.5','height':$(document.body).getScrollSize().y + 'px','width':$(document.body).getScrollSize().x + 'px'});
	},
	
	/**
	 * Display loading spinner
	 */
	_displayLoader: function() {
		$('cerabox-loading').setStyle('display','block');
		this._loaderAnimation();
	},
	
	/**
	 * Loader animation
	 * 
	 * @param int frame
	 */
	_loaderAnimation: function(frame) {
		if (!frame)
			frame=0;
		$('cerabox-loading').getElement('div').setStyle('top', (frame * -40) + 'px');
		frame = (frame + 1) % 12;
		
		if ($('cerabox-loading').getStyle('display')!='none')
			this._loaderAnimation.delay(60, this, frame);
	},
	
	/**
	 * Get size element object
	 * 
	 * @param object element
	 * @return object
	 */
	_getSizeElement: function(element, fullSize) {
		var eleWidth = 0, eleHeight = 0;
		
		if (element.tagName == 'IFRAME') {
			try {
				eleWidth = (element.get('width')?this._sizeStringToInt(element.get('width'),'x'):(element.getStyle('width').toInt()>1?this._sizeStringToInt(element.getStyle('width'),'x'):
					(element.contentWindow.document.getScrollWidth()?element.contentWindow.document.getScrollWidth():window.getSize().x * 0.75)));
			}
			catch(err) {
				eleWidth = window.getSize().x * 0.75;
				this._log(err); // IE6 fix
			}
			
			try {
				eleHeight = (element.get('height')?this._sizeStringToInt(element.get('height'),'y'):(element.getStyle('height').toInt()>1?this._sizeStringToInt(element.getStyle('height'),'y'):
					(element.contentWindow.document.getScrollHeight()?element.contentWindow.document.getScrollHeight():window.getSize().y * 0.75)));
			}
			catch(err) {
				eleHeight = window.getSize().y * 0.75;
				this._log(err); // IE6 fix
			}
			
			if (Browser.ie) {
				eleHeight = eleHeight + 20;
			}
			
			if (false===fullSize) {	
				if ((window.getSize().y - 100)<eleHeight) {
					eleWidth = eleWidth + (Browser.Platform.mac?15:17);
				}
				return {width: (window.getSize().x - 50)<eleWidth?(window.getSize().x - 50):eleWidth, height: (window.getSize().y - 100)<eleHeight?(window.getSize().y - 100):eleHeight};
			} else
				return {width: eleWidth, height: eleHeight};	
		}
		
		eleWidth = (element.get('width')?this._sizeStringToInt(element.get('width'),'x'):(element.getStyle('width')&&element.getStyle('width')!='auto'?this._sizeStringToInt(element.getStyle('width'),'x'):window.getSize().x - 50));
		eleHeight = (element.get('height')?this._sizeStringToInt(element.get('height'),'y'):(element.getStyle('height')&&element.getStyle('height')!='auto'?this._sizeStringToInt(element.getStyle('height'),'y'):window.getSize().y - 100));
		
		if (false===fullSize) {
			var r = Math.min(Math.min(window.getSize().x - 50, eleWidth) / eleWidth, Math.min(window.getSize().y - 100, eleHeight) / eleHeight);
			return {width: Math.round(r * eleWidth), height: Math.round(r * eleHeight)};
		}
		else
			return {width: eleWidth, height: eleHeight};
	},
	
	/**
	 * Get the pixels of given element size
	 * 
	 * @param string size
	 * @param string dimension 'x'|'y'
	 */
	_sizeStringToInt: function(size, dimension) {
		return (typeof size == 'string' && size.test('%')?window.getSize()[dimension]*(size.toInt()/100):size.toInt());
	},
	
	/**
	 * Resizing window
	 */
	_resize: function() {
		if(this.vars.windowOpen==true) {
			if (window.getSize().x > this.vars.cerabox.getSize().x+40) {
				this.vars.cerabox.setStyles({
					'margin-left':(this.vars.cerabox.getSize().x>0?((-this.vars.cerabox.getSize().x/2)+$(document.body).getScroll().x):0) + 'px',
					'left':'50%',
					'right':'auto'
				});
			}
			else {
				this.vars.cerabox.setStyles({
					'margin-left':'0',
					'left':'auto',
					'right':'20px'
				});
			}
			if (window.getSize().y > this.vars.cerabox.getSize().y+40) {
				this.vars.cerabox.setStyles({
					'margin-top':(this.vars.cerabox.getSize().y>0?((-this.vars.cerabox.getSize().y/2)+$(document.body).getScroll().y):0) + 'px',
					'top':'50%',
					'bottom':'auto'
				});
			}
			else {
				if (this.vars.cerabox.getSize().y+40 > ($(document.body).getScrollSize().y-$(document.body).getScroll().y)) {
					this.vars.cerabox.setStyles({
						'margin-top':'0',
						'top':($(document.body).getScrollSize().y-(this.vars.cerabox.getSize().y+60)>20?$(document.body).getScrollSize().y-(this.vars.cerabox.getSize().y+60):20) + 'px'
					});
				}
				else {
					this.vars.cerabox.setStyles({
						'margin-top':'0',
						'top':$(document.body).getScroll().y + 20 + 'px'
					});
				}
			}
			$('cerabox-background').setStyles({'height':$(document.body).getScrollSize().y + 'px','width':$(document.body).getScrollSize().x + 'px'});
		}
	},
	
	/**
	 * Add callback functions to cerabox
	 */
	_addCallbacks: function(events) {
		this.options.events._onClose	= null;
		this.options.events._onOpen		= null;
		this.options.events._onChange	= null;
		if (null !== events) {
			if (typeof events.onClose == 'function')
				this.options.events._onClose = events.onClose;
			if (typeof events.onOpen == 'function')
				this.options.events._onOpen = events.onOpen;
			if (typeof events.onChange == 'function')
				this.options.events._onChange = events.onChange;
		}
	},
	
	/**
	 * Simple logging function
	 */
	_log: function(log, alertIt) {
		try {
			console.log(log);
		}
		catch(err) {
			if (alertIt)
				alert(log);
		}
	}
});

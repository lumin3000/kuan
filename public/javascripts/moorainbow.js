/*
---

script: mooRainbow.js
version: 1.3
description: MooRainbow is a ColorPicker for MooTools 1.3
license: MIT-Style
authors:
  - Djamil Legato (w00fz)
  - Christopher Beloch

requires: [Core/*, More/Slider, More/Drag, More/Color]

provides: [mooRainbow]

...
*/
var color2code = {
"aliceblue":"#F0F8FF",
"antiquewhite":"#FAEBD7",
"aqua":"#00FFFF",
"aquamarine":"#7FFFD4",
"azure":"#F0FFFF",
"beige":"#F5F5DC",
"bisque":"#FFE4C4",
"black":"#000000",
"blanchedalmond":"#FFEBCD",
"blue":"#0000FF",
"blueviolet":"#8A2BE2",
"brown":"#A52A2A",
"burlywood":"#DEB887",
"cadetblue":"#5F9EA0",
"chartreuse":"#7FFF00",
"chocolate":"#D2691E",
"coral":"#FF7F50",
"cornflowerblue":"#6495ED",
"cornsilk":"#FFF8DC",
"crimson":"#DC143C",
"cyan":"#00FFFF",
"darkblue":"#00008B",
"darkcyan":"#008B8B",
"darkgoldenrod":"#B8860B",
"darkgray":"#A9A9A9",
"darkgreen":"#006400",
"darkkhaki":"#BDB76B",
"darkmagenta":"#8B008B",
"darkolivegreen":"#556B2F",
"darkorange":"#FF8C00",
"darkorchid":"#9932CC",
"darkred":"#8B0000",
"darksalmon":"#E9967A",
"darkseagreen":"#8FBC8F",
"darkslateblue":"#483D8B",
"darkslategray":"#2F4F4F",
"darkturquoise":"#00CED1",
"darkviolet":"#9400D3",
"deeppink":"#FF1493",
"deepskyblue":"#00BFFF",
"dimgray":"#696969",
"dodgerblue":"#1E90FF",
"firebrick":"#B22222",
"floralwhite":"#FFFAF0",
"forestgreen":"#228B22",
"fuchsia":"#FF00FF",
"gainsboro":"#DCDCDC",
"ghostwhite":"#F8F8FF",
"gold":"#FFD700",
"goldenrod":"#DAA520",
"gray":"#808080",
"green":"#008000",
"greenyellow":"#ADFF2F",
"honeydew":"#F0FFF0",
"hotpink":"#FF69B4",
"indianred":"#CD5C5C",
"indigo":"#4B0082",
"ivory":"#FFFFF0",
"khaki":"#F0E68C",
"lavender":"#E6E6FA",
"lavenderblush":"#FFF0F5",
"lawngreen":"#7CFC00",
"lemonchiffon":"#FFFACD",
"lightblue":"#ADD8E6",
"lightcoral":"#F08080",
"lightcyan":"#E0FFFF",
"lightgoldenrodyellow":"#FAFAD2",
"lightgreen":"#90EE90",
"lightgrey":"#D3D3D3",
"lightpink":"#FFB6C1",
"lightsalmon":"#FFA07A",
"lightseagreen":"#20B2AA",
"lightskyblue":"#87CEFA",
"lightslategray":"#778899",
"lightsteelblue":"#B0C4DE",
"lightyellow":"#FFFFE0",
"lime":"#00FF00",
"limegreen":"#32CD32",
"linen":"#FAF0E6",
"magenta":"#FF00FF",
"maroon":"#800000",
"mediumaquamarine":"#66CDAA",
"mediumblue":"#0000CD",
"mediumorchid":"#BA55D3",
"mediumpurple":"#9370DB",
"mediumseagreen":"#3CB371",
"mediumslateblue":"#7B68EE",
"mediumspringgreen":"#00FA9A",
"mediumturquoise":"#48D1CC",
"mediumvioletred":"#C71585",
"midnightblue":"#191970",
"mintcream":"#F5FFFA",
"mistyrose":"#FFE4E1",
"moccasin":"#FFE4B5",
"navajowhite":"#FFDEAD",
"navy":"#000080",
"oldlace":"#FDF5E6",
"olive":"#808000",
"olivedrab":"#6B8E23",
"orange":"#FFA500",
"orangered":"#FF4500",
"orchid":"#DA70D6",
"palegoldenrod":"#EEE8AA",
"palegreen":"#98FB98",
"paleturquoise":"#AFEEEE",
"palevioletred":"#DB7093",
"papayawhip":"#FFEFD5",
"peachpuff":"#FFDAB9",
"peru":"#CD853F",
"pink":"#FFC0CB",
"plum":"#DDA0DD",
"powderblue":"#B0E0E6",
"purple":"#800080",
"red":"#FF0000",
"rosybrown":"#BC8F8F",
"royalblue":"#4169E1",
"saddlebrown":"#8B4513",
"salmon":"#FA8072",
"sandybrown":"#F4A460",
"seagreen":"#2E8B57",
"seashell":"#FFF5EE",
"sienna":"#A0522D",
"silver":"#C0C0C0",
"skyblue":"#87CEEB",
"slateblue":"#6A5ACD",
"slategray":"#708090",
"snow":"#FFFAFA",
"springgreen":"#00FF7F",
"steelblue":"#4682B4",
"tan":"#D2B48C",
"teal":"#008080",
"thistle":"#D8BFD8",
"tomato":"#FF6347",
"turquoise":"#40E0D0",
"violet":"#EE82EE",
"wheat":"#F5DEB3",
"white":"#FFFFFF",
"whitesmoke":"#F5F5F5",
"yellow":"#FFFF00",
"yellowgreen":"#9ACD32"
} 
$chk = function(obj){
  return !!(obj || obj === 0);
};

var MooRainbow = new Class({
	options: {
		id: 'mooRainbow',
		prefix: 'moor-',
		imgPath: 'images/',
		startColor: [255, 0, 0],
		wheel: false,
		onComplete: Class.empty,
	  onChange: Class.empty,
          onCancel: Class.empty
	},
	
	initialize: function(el, options) {
		this.element = $(el); if (!this.element) return;
		this.setOptions(options);
		
		this.sliderPos = 0;
		this.pickerPos = {x: 0, y: 0};
		this.backupColor = this.options.startColor;
		this.currentColor = this.options.startColor;
		this.sets = {
			rgb: [],
			hsb: [],
			hex: []	
		};
		this.pickerClick = this.sliderClick  = false;
		if (!this.layout) this.doLayout();
		this.OverlayEvents();
		this.sliderEvents();
		this.backupEvent();
		if (this.options.wheel) this.wheelEvents();
		this.element.addEvent('click', function(e) { this.toggle(e); }.bind(this));
				
		this.layout.overlay.setStyle('background-color', this.options.startColor.rgbToHex());
		this.layout.backup.setStyle('background-color', this.backupColor.rgbToHex());

		this.pickerPos.x = this.snippet('curPos').l + this.snippet('curSize', 'int').w;
		this.pickerPos.y = this.snippet('curPos').t + this.snippet('curSize', 'int').h;
		
		this.manualSet(this.options.startColor);
		
		this.pickerPos.x = this.snippet('curPos').l + this.snippet('curSize', 'int').w;
		this.pickerPos.y = this.snippet('curPos').t + this.snippet('curSize', 'int').h;
		this.sliderPos = this.snippet('arrPos') - this.snippet('arrSize', 'int');

		if (window.khtml) this.hide();
	},
	
	toggle: function() {
		this[this.visible ? 'hide' : 'show']()
	},
	
	show: function() {
		this.rePosition();
		this.layout.setStyle('display', 'block');
		this.visible = true;
          document.body.set('mask', {onClick: function(){
            document.body.unmask()
            this.hide()
	    this.fireEvent('onCancel', [this.sets, this]);
          }.bind(this)}).mask()
          this.layout.setStyle('z-index', 9999)
	},
	
	hide: function() {
		this.layout.setStyles({'display': 'none'});
		this.visible = false;
          document.body.unmask()
	},
	
	manualSet: function(color, type) {
		if (!type || (type != 'hsb' && type != 'hex')) type = 'rgb';
		var rgb, hsb, hex;

		if (type == 'rgb') { rgb = color; hsb = color.rgbToHsb(); hex = color.rgbToHex(); } 
		else if (type == 'hsb') { hsb = color; rgb = color.hsbToRgb(); hex = rgb.rgbToHex(); }
		else { hex = color; rgb = color.hexToRgb(true); hsb = rgb.rgbToHsb(); }
		
		this.setMooRainbow(rgb);
		this.autoSet(hsb);
	},
	
	autoSet: function(hsb) {
		var curH = this.snippet('curSize', 'int').h;
		var curW = this.snippet('curSize', 'int').w;
		var oveH = this.layout.overlay.height;
		var oveW = this.layout.overlay.width;
		var sliH = this.layout.slider.height;
		var arwH = this.snippet('arrSize', 'int');
		var hue;
		
		var posx = Math.round(((oveW * hsb[1]) / 100) - curW);
		var posy = Math.round(- ((oveH * hsb[2]) / 100) + oveH - curH);

		var c = Math.round(((sliH * hsb[0]) / 360)); c = (c == 360) ? 0 : c;
		var position = sliH - c + this.snippet('slider') - arwH;
		hue = [this.sets.hsb[0], 100, 100].hsbToRgb().rgbToHex();
		
		this.layout.cursor.setStyles({'top': posy, 'left': posx});
		this.layout.arrows.setStyle('top', position);
		this.layout.overlay.setStyle('background-color', hue);
		this.sliderPos = this.snippet('arrPos') - arwH;
		this.pickerPos.x = this.snippet('curPos').l + curW;
		this.pickerPos.y = this.snippet('curPos').t + curH;
	},
	
	setMooRainbow: function(color, type) {
		if (!type || (type != 'hsb' && type != 'hex')) type = 'rgb';
		var rgb, hsb, hex;

		if (type == 'rgb') { rgb = color; hsb = color.rgbToHsb(); hex = color.rgbToHex(); } 
		else if (type == 'hsb') { hsb = color; rgb = color.hsbToRgb(); hex = rgb.rgbToHex(); }
		else { hex = color; rgb = color.hexToRgb(); hsb = rgb.rgbToHsb(); }

		this.sets = {
			rgb: rgb,
			hsb: hsb,
			hex: hex
		};

		if (!this.pickerPos.x)
			this.autoSet(hsb);		

		this.RedInput.value = rgb[0];
		this.GreenInput.value = rgb[1];
		this.BlueInput.value = rgb[2];
		this.HueInput.value = hsb[0];
		this.SatuInput.value =  hsb[1];
		this.BrighInput.value = hsb[2];
		this.hexInput.value = hex;
		
		this.currentColor = rgb;

		this.chooseColor.setStyle('background-color', rgb.rgbToHex());
		
		this.fireEvent('onChange', [this.sets, this]);
	},
	
	parseColors: function(x, y, z) {
		var s = Math.round((x * 100) / this.layout.overlay.width);
		var b = 100 - Math.round((y * 100) / this.layout.overlay.height);
		var h = 360 - Math.round((z * 360) / this.layout.slider.height) + this.snippet('slider') - this.snippet('arrSize', 'int');
		h -= this.snippet('arrSize', 'int');
		h = (h >= 360) ? 0 : (h < 0) ? 0 : h;
		s = (s > 100) ? 100 : (s < 0) ? 0 : s;
		b = (b > 100) ? 100 : (b < 0) ? 0 : b;

		return [h, s, b];
	},
	
	OverlayEvents: function() {
		var lim, curH, curW, inputs;
		curH = this.snippet('curSize', 'int').h;
		curW = this.snippet('curSize', 'int').w;
		inputs = this.arrRGB.concat(this.arrHSB, this.hexInput);

		document.addEvent('click', function() { 
		  if(this.visible){
	            this.fireEvent('onCancel', [this.sets, this]);
                    this.hide(this.layout); 
                  }
		}.bind(this));

		inputs.each(function(el) {
			el.addEvent('keydown', this.eventKeydown.bind(this, el));
			el.addEvent('keyup', this.eventKeyup.bind(this, el));
		}, this);
		[this.element, this.layout].each(function(el) {
			el.addEvents({
				'click': function(e) { new Event(e).stop(); },
				'keyup': function(e) {
					e = new Event(e);
				  if(e.key == 'esc' && this.visible){
	                            this.fireEvent('onCancel', [this.sets, this]);
                                    this.hide(this.layout);
                                  }
				}.bind(this)
			}, this);
		}, this);
		
		lim = {
			x: [0 - curW, (this.layout.overlay.width - curW)],
			y: [0 - curH, (this.layout.overlay.height - curH)]
		};

		this.layout.drag = new Drag(this.layout.cursor, {
			onStart: this.overlayDrag.bind(this),
			onDrag: this.overlayDrag.bind(this),
			snap: 0
		});	
		
		this.layout.overlay2.addEvent('mousedown', function(e){
			e = new Event(e);
			this.layout.cursor.setStyles({
				'top': e.page.y - this.layout.overlay.getTop() - curH,
				'left': e.page.x - this.layout.overlay.getLeft() - curW
			});
                  this.overlayDrag.call(this)
			this.layout.drag.start(e);
		}.bind(this));
		
		this.okButton.addEvent('click', function() {
			if(this.currentColor == this.options.startColor) {
				this.hide();
				this.fireEvent('onComplete', [this.sets, this]);
			}
			else {
				this.backupColor = this.currentColor;
				this.layout.backup.setStyle('background-color', this.backupColor.rgbToHex());
				this.hide();
				this.fireEvent('onComplete', [this.sets, this]);
			}
                  return false
		}.bind(this));
		this.cancelButton.addEvent('click', function() {
	          this.fireEvent('onCancel', [this.sets, this]);
		  this.hide();
                  return false
		}.bind(this));
	},
	
	overlayDrag: function() {
		var curH = this.snippet('curSize', 'int').h;
		var curW = this.snippet('curSize', 'int').w;
		this.pickerPos.x = this.snippet('curPos').l + curW;
		this.pickerPos.y = this.snippet('curPos').t + curH;
		
		this.setMooRainbow(this.parseColors(this.pickerPos.x, this.pickerPos.y, this.sliderPos), 'hsb');
		this.fireEvent('onChange', [this.sets, this]);
	},
	
	sliderEvents: function() {
		var arwH = this.snippet('arrSize', 'int'), lim;

		lim = [0 + this.snippet('slider') - arwH, this.layout.slider.height - arwH + this.snippet('slider')];
		this.layout.sliderDrag = new Drag(this.layout.arrows, {
			limit: {y: lim},
			modifiers: {x: false},
			onStart: this.sliderDrag.bind(this),
			onDrag: this.sliderDrag.bind(this),
			snap: 0
		});	
	
		this.layout.slider.addEvent('mousedown', function(e){
			e = new Event(e);

			this.layout.arrows.setStyle(
				'top', e.page.y - this.layout.slider.getTop() + this.snippet('slider') - arwH
			);
                  this.sliderDrag.call(this)
			this.layout.sliderDrag.start(e);
		}.bind(this));
	},

	sliderDrag: function() {
		var arwH = this.snippet('arrSize', 'int'), hue;
		
		this.sliderPos = this.snippet('arrPos') - arwH;
		this.setMooRainbow(this.parseColors(this.pickerPos.x, this.pickerPos.y, this.sliderPos), 'hsb');
		hue = [this.sets.hsb[0], 100, 100].hsbToRgb().rgbToHex();
		this.layout.overlay.setStyle('background-color', hue);
		this.fireEvent('onChange', [this.sets, this]);
	},
	
	backupEvent: function() {
		this.layout.backup.addEvent('click', function() {
			this.manualSet(this.backupColor);
			this.fireEvent('onChange', [this.sets, this]);
		}.bind(this));
	},
	
	wheelEvents: function() {
		var arrColors = this.arrRGB.copy().extend(this.arrHSB);

		arrColors.each(function(el) {
			el.addEvents({
				'mousewheel': this.eventKeys.bindWithEvent(this, el),
				'keydown': this.eventKeys.bindWithEvent(this, el)
			});
		}, this);
		
		[this.layout.arrows, this.layout.slider].each(function(el) {
			el.addEvents({
				'mousewheel': this.eventKeys.bindWithEvent(this, [this.arrHSB[0], 'slider']),
				'keydown': this.eventKeys.bindWithEvent(this, [this.arrHSB[0], 'slider'])
			});
		}, this);
	},
	
	eventKeys: function(e, el, id) {
		var wheel, type;		
		id = (!id) ? el.id : this.arrHSB[0];

		if (e.type == 'keydown') {
			if (e.key == 'up') wheel = 1;
			else if (e.key == 'down') wheel = -1;
			else return;
		} else if (e.type == Element.Events.mousewheel.type) wheel = (e.wheel > 0) ? 1 : -1;

		if (this.arrRGB.test(el)) type = 'rgb';
		else if (this.arrHSB.test(el)) type = 'hsb';
		else type = 'hsb';

		if (type == 'rgb') {
			var rgb = this.sets.rgb, hsb = this.sets.hsb, prefix = this.options.prefix, pass;
			var value = el.value.toInt() + wheel;
			value = (value > 255) ? 255 : (value < 0) ? 0 : value;

			switch(el.className) {
				case prefix + 'rInput': pass = [value, rgb[1], rgb[2]];	break;
				case prefix + 'gInput': pass = [rgb[0], value, rgb[2]];	break;
				case prefix + 'bInput':	pass = [rgb[0], rgb[1], value];	break;
				default : pass = rgb;
			}
			this.manualSet(pass);
			this.fireEvent('onChange', [this.sets, this]);
		} else {
			var rgb = this.sets.rgb, hsb = this.sets.hsb, prefix = this.options.prefix, pass;
			var value = el.value.toInt() + wheel;

			if (el.className.test(/(HueInput)/)) value = (value > 359) ? 0 : (value < 0) ? 0 : value;
			else value = (value > 100) ? 100 : (value < 0) ? 0 : value;

			switch(el.className) {
				case prefix + 'HueInput': pass = [value, hsb[1], hsb[2]]; break;
				case prefix + 'SatuInput': pass = [hsb[0], value, hsb[2]]; break;
				case prefix + 'BrighInput':	pass = [hsb[0], hsb[1], value]; break;
				default : pass = hsb;
			}
			this.manualSet(pass, 'hsb');
			this.fireEvent('onChange', [this.sets, this]);
		}
		e.stop();
	},
	
	eventKeydown: function(el, e) {
		var n = e.code, k = e.key;

		if 	((!el.className.test(/hexInput/) && !(n >= 48 && n <= 57)) &&
			(k!='backspace' && k!='tab' && k !='delete' && k!='left' && k!='right'))
		e.stop();
	},
	
	eventKeyup: function(el, e) {
		var n = e.code, k = e.key, pass, prefix, chr = el.value.charAt(0);
		if (!$chk(el.value)) return;
		if (el.className.test(/hexInput/)) {
			if (chr != "#" && el.value.length != 6) return;
			if (chr == '#' && el.value.length != 7) return;
		} else {
			if (!(n >= 48 && n <= 57) && (!['backspace', 'tab', 'delete', 'left', 'right'].test(k)) && el.value.length > 3) return;
		}
		
		prefix = this.options.prefix;

		if (el.className.test(/(rInput|gInput|bInput)/)) {
			if (el.value  < 0 || el.value > 255) return;
			switch(el.className){
				case prefix + 'rInput': pass = [el.value, this.sets.rgb[1], this.sets.rgb[2]]; break;
				case prefix + 'gInput': pass = [this.sets.rgb[0], el.value, this.sets.rgb[2]]; break;
				case prefix + 'bInput': pass = [this.sets.rgb[0], this.sets.rgb[1], el.value]; break;
				default : pass = this.sets.rgb;
			}
			this.manualSet(pass);
			this.fireEvent('onChange', [this.sets, this]);
		}
		else if (!el.className.test(/hexInput/)) {
			if (el.className.test(/HueInput/) && el.value  < 0 || el.value > 360) return;
			else if (el.className.test(/HueInput/) && el.value == 360) el.value = 0;
			else if (el.className.test(/(SatuInput|BrighInput)/) && el.value  < 0 || el.value > 100) return;
			switch(el.className){
				case prefix + 'HueInput': pass = [el.value, this.sets.hsb[1], this.sets.hsb[2]]; break;
				case prefix + 'SatuInput': pass = [this.sets.hsb[0], el.value, this.sets.hsb[2]]; break;
				case prefix + 'BrighInput': pass = [this.sets.hsb[0], this.sets.hsb[1], el.value]; break;
				default : pass = this.sets.hsb;
			}
			this.manualSet(pass, 'hsb');
			this.fireEvent('onChange', [this.sets, this]);
		} else {
			pass = el.value.hexToRgb(true);
			if (isNaN(pass[0])||isNaN(pass[1])||isNaN(pass[2])) return;
          $chk = function(obj){
	    return !!(obj || obj === 0);
          };
			if ($chk(pass)) {
				this.manualSet(pass);
				this.fireEvent('onChange', [this.sets, this]);
			}
		}
			
	},
			
	doLayout: function() {
		var id = this.options.id, prefix = this.options.prefix;
		var idPrefix = id + ' .' + prefix;

		this.layout = new Element('div', {
			'styles': {'display': 'block', 'position': 'absolute'},
			'id': id
		}).inject(document.body);

		var box = new Element('div', {
			'styles':  {'position': 'relative'},
			'class': prefix + 'box'
		}).inject(this.layout);
			
		var div = new Element('div', {
			'styles': {'position': 'absolute', 'overflow': 'hidden'},
			'class': prefix + 'overlayBox'
		}).inject(box);
		
		var ar = new Element('div', {
			'styles': {'position': 'absolute', 'zIndex': 1},
			'class': prefix + 'arrows'
		}).inject(box);
		ar.width = ar.getStyle('width').toInt();
		ar.height = ar.getStyle('height').toInt();
		
		var ov = new Element('img', {
			'styles': {'background-color': '#fff', 'position': 'relative', 'zIndex': 2},
			'src': this.options.imgPath + 'moor_woverlay.png',
			'class': prefix + 'overlay'
		}).inject(div);
		
		var ov2 = new Element('img', {
			'styles': {'position': 'absolute', 'top': 0, 'left': 0, 'zIndex': 2},
			'src': this.options.imgPath + 'moor_boverlay.png',
			'class': prefix + 'overlay'
		}).inject(div);
		
		if (window.ie6) {
			div.setStyle('overflow', '');
			var src = ov.src;
			ov.src = this.options.imgPath + 'blank.gif';
			ov.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "', sizingMethod='scale')";
			src = ov2.src;
			ov2.src = this.options.imgPath + 'blank.gif';
			ov2.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "', sizingMethod='scale')";
		}
		ov.width = ov2.width = div.getStyle('width').toInt();
		ov.height = ov2.height = div.getStyle('height').toInt();

		var cr = new Element('div', {
			'styles': {'overflow': 'hidden', 'position': 'absolute', 'zIndex': 2},
			'class': prefix + 'cursor'	
		}).inject(div);
		cr.width = cr.getStyle('width').toInt();
		cr.height = cr.getStyle('height').toInt();
		
		var sl = new Element('img', {
			'styles': {'position': 'absolute', 'z-index': 2},
			'src': this.options.imgPath + 'moor_slider.png',
			'class': prefix + 'slider'
		}).inject(box);
		this.layout.slider = Slick.find(document, '#' + idPrefix + 'slider');
		sl.width = sl.getStyle('width').toInt();
		sl.height = sl.getStyle('height').toInt();

		new Element('div', {
			'styles': {'position': 'absolute'},
			'class': prefix + 'colorBox'
		}).inject(box);

		new Element('div', {
			'styles': {'zIndex': 2, 'position': 'absolute'},
			'class': prefix + 'chooseColor'
		}).inject(box);
			
		this.layout.backup = new Element('div', {
			'styles': {'zIndex': 2, 'position': 'absolute', 'cursor': 'pointer'},
			'class': prefix + 'currentColor'
		}).inject(box);
		
		var R = new Element('label').inject(box).setStyle('position', 'absolute');
		var G = R.clone().inject(box).addClass(prefix + 'gLabel').appendText('G: ');
		var B = R.clone().inject(box).addClass(prefix + 'bLabel').appendText('B: ');
		R.appendText('R: ').addClass(prefix + 'rLabel');
		
		var inputR = new Element('input');
		var inputG = inputR.clone().inject(G).addClass(prefix + 'gInput');
		var inputB = inputR.clone().inject(B).addClass(prefix + 'bInput');
		inputR.inject(R).addClass(prefix + 'rInput');
		
		var HU = new Element('label').inject(box).setStyle('position', 'absolute');
		var SA = HU.clone().inject(box).addClass(prefix + 'SatuLabel').appendText('S: ');
		var BR = HU.clone().inject(box).addClass(prefix + 'BrighLabel').appendText('B: ');
		HU.appendText('H: ').addClass(prefix + 'HueLabel');

		var inputHU = new Element('input');
		var inputSA = inputHU.clone().inject(SA).addClass(prefix + 'SatuInput');
		var inputBR = inputHU.clone().inject(BR).addClass(prefix + 'BrighInput');
		inputHU.inject(HU).addClass(prefix + 'HueInput');
		SA.appendText(' %'); BR.appendText(' %');
		(new Element('span', {'styles': {'position': 'absolute'}, 'class': prefix + 'ballino'}).set('html', " &deg;").inject(HU, 'after'));

		var hex = new Element('label').inject(box).setStyle('position', 'absolute').addClass(prefix + 'hexLabel').appendText('#hex: ').adopt(new Element('input').addClass(prefix + 'hexInput'));
		
		var ok = new Element('a', {
			'styles': {'position': 'absolute'},
			'href': '#',
			'html': '确定',
			'class': prefix + 'okButton'
		}).inject(box);
		var cancel = new Element('a', {
			'styles': {'position': 'absolute'},
			'href': '#',
			'html': '取消',
			'class': prefix + 'cancelButton'
		}).inject(box);
		
		this.rePosition();

		var overlays = $$('#' + idPrefix + 'overlay');
		this.layout.overlay = overlays[0];
		this.layout.overlay2 = overlays[1];
		this.layout.cursor = Slick.find(document, '#' + idPrefix + 'cursor');
		this.layout.arrows = Slick.find(document, '#' + idPrefix + 'arrows');
		this.chooseColor = Slick.find(document, '#' + idPrefix + 'chooseColor');
		this.layout.backup = Slick.find(document, '#' + idPrefix + 'currentColor');
		this.RedInput = Slick.find(document, '#' + idPrefix + 'rInput');
		this.GreenInput = Slick.find(document, '#' + idPrefix + 'gInput');
		this.BlueInput = Slick.find(document, '#' + idPrefix + 'bInput');
		this.HueInput = Slick.find(document, '#' + idPrefix + 'HueInput');
		this.SatuInput = Slick.find(document, '#' + idPrefix + 'SatuInput');
		this.BrighInput = Slick.find(document, '#' + idPrefix + 'BrighInput');
		this.hexInput = Slick.find(document, '#' + idPrefix + 'hexInput');

		this.arrRGB = [this.RedInput, this.GreenInput, this.BlueInput];
		this.arrHSB = [this.HueInput, this.SatuInput, this.BrighInput];
		this.okButton = Slick.find(document, '#' + idPrefix + 'okButton');
		this.cancelButton = Slick.find(document, '#' + idPrefix + 'cancelButton');
		
		this.layout.cursor.setStyle('background-image', 'url(' + this.options.imgPath + 'moor_cursor.gif)');
		
		if (!window.khtml) this.hide();
	},
	rePosition: function() {
		var coords = this.element.getCoordinates();
		this.layout.setStyles({
			'left': coords.left,
			'top': coords.top + coords.height + 1
		});
	},
	
	snippet: function(mode, type) {
		var size; type = (type) ? type : 'none';

		switch(mode) {
			case 'arrPos':
				var t = this.layout.arrows.getStyle('top').toInt();
				size = t;
				break;
			case 'arrSize': 
				var h = this.layout.arrows.height;
				h = (type == 'int') ? (h/2).toInt() : h;
				size = h;
				break;		
			case 'curPos':
				var l = this.layout.cursor.getStyle('left').toInt();
				var t = this.layout.cursor.getStyle('top').toInt();
				size = {'l': l, 't': t};
				break;
			case 'slider':
				var t = this.layout.slider.getStyle('marginTop').toInt();
				size = t;
				break;
			default :
				var h = this.layout.cursor.height;
				var w = this.layout.cursor.width;
				h = (type == 'int') ? (h/2).toInt() : h;
				w = (type == 'int') ? (w/2).toInt() : w;
				size = {w: w, h: h};
		};
		return size;
	}
});

MooRainbow.implement(new Options);
MooRainbow.implement(new Events);

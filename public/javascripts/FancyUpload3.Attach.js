/**
 * FancyUpload.Attach - Flash meets Ajax for powerful and elegant uploads.
 *
 * @version		3.0 rc3
 *
 * @license		MIT License
 *
 * @author		Harald Kirschner <mail [at] digitarald [dot] de>
 * @copyright	Authors
 */

if (!window.FancyUpload3) var FancyUpload3 = {};

FancyUpload3.Attach = new Class({

	Extends: Swiff.Uploader,
	
	options: {
		queued: false,
		instantStart: true
	},

	initialize: function(list, selects, options) {
		this.list = $(list);
		this.selects = $(selects) ? $$($(selects)) : $$(selects);
				
		options.target = this.selects[0];
		options.fileClass = options.fileClass || FancyUpload3.Attach.File;
		
		this.parent(options);

		/**
		 * Button state
		 */
		var self = this;
		
		this.selects.addEvents({
			click: function() {
				return false;
			},
			mouseenter: function() {
				this.addClass('hover');
				self.reposition();
			},
			mouseleave: function() {
				this.removeClass('hover');
				this.blur();
			},
			mousedown: function() {
				this.focus();
			}
		});
		
		if (this.selects.length == 2) {
			this.selects[1].setStyle('display', 'none');
			this.addEvents({
				'selectSuccess': this.onSelectSuccess,
				'fileRemove': this.onFileRemove
			});
		}
	},
	
	onSelectSuccess: function() {
		if (this.fileList.length > 0) {
			this.selects[0].setStyle('display', 'none');
			this.selects[1].setStyle('display', 'inline');
			this.target = this.selects[1];
			this.reposition();
		}
	},
	
	onFileRemove: function() {
		if (this.fileList.length == 0) {
			this.selects[0].setStyle('display', 'inline');
			this.selects[1].setStyle('display', 'none');
			this.target = this.selects[0];
			this.reposition();
		}
	},
	
	start: function() {
		// if (Browser.Platform.linux && window.confirm(MooTools.lang.get('FancyUpload', 'linuxWarning'))) return this;
		//if (Browser.Platform.linux)window.alert(MooTools.lang.get('FancyUpload', 'linuxWarning'));
		return this.parent();
	}
	
});

FancyUpload3.Attach.File = new Class({

	Extends: Swiff.Uploader.File,

	render: function() {
		
		if (this.invalid) {
			if (this.validationError) {
				var msg = MooTools.lang.get('FancyUpload', 'validationErrors')[this.validationError] || this.validationError;
				this.validationErrorMessage = msg.substitute({
					name: this.name,
					size: Swiff.Uploader.formatUnit(this.size, 'b'),
					fileSizeMin: Swiff.Uploader.formatUnit(this.base.options.fileSizeMin || 0, 'b'),
					fileSizeMax: Swiff.Uploader.formatUnit(this.base.options.fileSizeMax || 0, 'b'),
					fileListMax: this.base.options.fileListMax || 0,
					fileListSizeMax: Swiff.Uploader.formatUnit(this.base.options.fileListSizeMax || 0, 'b')
				});
			}
			this.remove();
			return;
		}
		
		this.addEvents({
			'open': this.onOpen,
			'remove': this.onRemove,
			'requeue': this.onRequeue,
			'progress': this.onProgress,
			'stop': this.onStop,
			'complete': this.onComplete,
			'error': this.onError
		});
		
		this.ui = {};
		
		this.ui.element = new Element('div', {'class': 'file clearfix', id: 'file-' + this.id});
		this.ui.title = new Element('span', {'class': 'file-title', text: this.name.replace(/^(.{3}).{4,}(.{6})$/,'$1...$2'), 'title':this.name});
		//this.ui.size = new Element('span', {'class': 'file-size', text: Swiff.Uploader.formatUnit(this.size, 'b')});
		this.ui.size = new Element('span', {'class': 'file-size', text: ''});
		
		this.ui.cancel = new Element('a', {'class': 'file-cancel', 'html': '<span>取消</span>', 'href': '#'});
		this.ui.cancel.addEvent('click', function() {
			this.remove();
			return false;
		}.bind(this));

		// this.ui.element.adopt(
		// 	this.ui.a_target,
		// 	this.ui.title,
		// 	this.ui.size,
		// 	this.ui.cancel,
		// ).inject(this.base.list).highlight('#e6efc2', '#F8F8F8');
		// typeof KT.sort != 'undefined' && KT.sort && KT.sort.addItems(this.ui.element);
		
		// var progress = new Element('img', {'class': 'file-progress', src: '/images/progress-bar/bar.gif'}).inject(this.ui.size, 'after');
		// this.ui.progress = new Fx.ProgressBar(progress, {
		// 	fit: true
		// }).set(0);
					
		this.base.reposition();

		return this.parent();
	},

	onOpen: function() {
		this.ui.element.addClass('file-uploading');
		if (this.ui.progress) this.ui.progress.set(0);
	},

	onRemove: function() {
		this.ui = this.ui.element.destroy();
	},

	onProgress: function() {
		if (this.ui.progress) this.ui.progress.start(this.progress.percentLoaded);
	},

	onStop: function() {
		this.remove();
	},
	
	onComplete: function() {
		this.ui.element.removeClass('file-uploading');

		if (this.response.error) {
			var msg = MooTools.lang.get('FancyUpload', 'errors')[this.response.error] || '{error} #{code}';
			this.errorMessage = msg.substitute($extend({name: this.name}, this.response));
			
			this.base.fireEvent('fileError', [this, this.response, this.errorMessage]);
			this.fireEvent('error', [this, this.response, this.errorMessage]);
			return;
		}
		
		if (this.ui.progress) this.ui.progress = this.ui.progress.cancel().element.destroy();
		this.ui.cancel = this.ui.cancel.destroy();
		
		var response = this.response.text || '';
		this.base.fireEvent('fileSuccess', [this, response]);
	},

	onError: function() {
		this.ui.element.addClass('file-failed');		
	}

});

//Avoiding MooTools.lang dependency
(function() {
	var phrases = {
		'fileName': '{name}',
		'cancel': '取消',
		'cancelTitle': '点击取消',
		'validationErrors': {
			'duplicate': '已经有<em>{name}</em>，不能重复上传',
			'sizeLimitMin': '文件<em>{name}</em> (<em>{size}</em>)太小，允许最小值为{fileSizeMin}.',
			'sizeLimitMax': '文件<em>{name}</em> (<em>{size}</em>)太大，请不要超过<em>{fileSizeMax}</em>.',
			'fileListMax': '<em>{name}</em>添加失败，每次最多能上传<em>{fileListMax}个</em>文件',
			'fileListSizeMax': '<em>{name}</em> (<em>{size}</em>)太大，文件总共不能超过<em>{fileListSizeMax}</em>'
		},
		'errors': {
			'httpStatus': '链接失败 #{code}',
			'securityError': '安全错误 ({text})',
			'ioError': '上传失败 ({text})'
		},
		'linuxWarning': '注意：因为Flash在Linux上的bug，浏览器可能会临时冻结，\n是否确定上传？'
	};
	
	if (MooTools.lang) {
		MooTools.lang.set('en-US', 'FancyUpload', phrases);
	} else {
		MooTools.lang = {
			get: function(from, key) {
				return phrases[key];
			}
		};
	}
	
})();

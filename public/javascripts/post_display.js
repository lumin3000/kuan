K.Slide = {
  Stage: new Class({
    initialize: function(conf) {
      conf = conf || {}
      this.images = conf.images.map(function(i) {
        return new K.Slide.Item(i)
      })
      this.current = 0
      this.minHeight = conf.minHeight || 200
      this.width = conf.width || 500
      this.interval = conf.interval || 5000
    }
  , Implements: Events
  , show: function(context) {
      var self = this
        , num = this.images.length
      this.bindContext(context)
      this.images.each(function(img) {
        var el = document.createElement("img")
        el.onload = function() {
          img.height = this.height
          img.width = this.width
          self.extendHeight(img.height)
          setTimeout(function() {
            if (--num) return
            self.finishPending()
            self.render()
            self.play()
          }, 1)
        }
        el.src = img.normalSize
      })
      this.pend()
    }
  , pend: function() {
      this.context.setStyles({
        width: this.width
      , height: this.minHeight
      })
      new Element("img", {
        width: 16
      , height: 16
      , src: K.Slide.busyIndicator
      }).addClass("pending_indicator").inject(this.context)
    }
  , finishPending: function() {
      var indicator = this.context.getElement(".pending_indicator")
      indicator && indicator.empty().dispose()
    }
  , bindContext: function(context) {
      var self = this
      this.context = context
      context.addEvents({
        mouseenter: function() {
          self.hovering = true
          self.fireEvent("focus")
        }
      , mouseleave: function() {
          self.hovering = false
          setTimeout(function() {
            if (!self.hovering) self.fireEvent("blur")
          }, 1500)
        }
      })
    }
  , extendHeight: function(height) {
      this.minHeight = Math.max(this.minHeight, height)
    }
  , render: function() {
      var img = this.images[this.current]
        , elem = img.toElement()
        , context = this.context
      context.setStyle("height", this.minHeight)
      var prev = context.getElement(".slide_item")
      if (prev) {
        prev.fade("out")
        setTimeout(function() {
          prev.empty().dispose()
        }, 2 * 1000)
      }
      elem.setStyle("visibility", "hidden").inject(context, "top")
      setTimeout(function() {
        elem.position({relativeTo: context}).setStyle("visibility", "visible")
      }, 100)
      context.getElement(".slide_desc")
        .set("html", img.desc || "")
        .getParent(".slide_desc_wrapper")
        .setStyle("visibility", img.desc ? "visible" : "hidden")
      if (K.lightbox && typeof K.lightbox.refresh == "function") {
        K.lightbox.refresh()
      }
    }
  , next: function() {
      this.current++
      if (this.current >= this.images.length) this.current = 0
      this.render()
      this.resetInterval()
    }
  , prev: function() {
      this.current--
      if (this.current < 0) this.current = this.images.length - 1
      this.render()
      this.resetInterval()
    }
  , toThumbList: function() {
      var self = this
      return this.images.map(function(img, i) {
        return new Element("li", {
          "class": "slide_thumb"
        }).adopt(
          new Element("img", {
            src: img.thumbnail
          , title: img.desc
          , events: {
              click: function() {
                if (self.current == i) return
                self.current = i
                self.hideThumbList()
                self.render()
              }
            }
          })
        )
      })
    }
  , showThumbList: function() {
      if (this.showingThumbList) return
      var size = this.context.getSize()
        , list = new Element("ul").adopt(this.toThumbList()).addClass("thumblist")
        , shim = new Element("div", {
            styles: {
              opacity: 0.5
            , position: "absolute"
            , top: 0
            , left: 0
            , backgroundColor: "#000"
            , width: size.x
            , height: size.y
            }
          , html: "&nbsp;"
          }).addClass("slide_thumb_shim")
      this.context.adopt(list).adopt(shim)
      list.position({
        relativeTo: this.context
      })
      this.shim = shim
      this.thumbList = list
      this.showingThumbList = true
      this.context.addClass("showing_thumblist")
      if (this.playing) {
        this.pausedOnThumbList = true
        this.pause()
      }
    }
  , hideThumbList: function() {
      if (!this.showingThumbList) return
      this.thumbList.empty().dispose()
      this.shim.empty().dispose()
      delete this.shim
      delete this.thumbList
      this.showingThumbList = false
      this.context.removeClass("showing_thumblist")
      if (this.pausedOnThumbList) {
        this.pausedOnThumbList = false
        this.play()
      }
    }
  , play: function() {
      if (this.playing) return
      this.playing = true
      this.context.addClass("slide_playing")
      this.setInterval()
    }
  , setInterval: function() {
      this.intervalHandler = setInterval(this.next.bind(this), this.interval)
    }
  , resetInterval: function() {
      if (!this.playing) return
      clearInterval(this.intervalHandler)
      this.setInterval()
    }
  , proceedAndPlay: function() {
      this.next()
      this.play()
    }
  , pause: function() {
      if (!this.playing) return
      this.playing = false
      this.context.removeClass("slide_playing")
      clearInterval(this.intervalHandler)
    }
  })
, Controller: new Class({
    initialize: function(panel) {
      this.panel = panel
    }
  , control: function(slide) {
      this.slide = slide
      this.slide.addEvents({
        focus: this.show.bind(this)
      , blur: this.hide.bind(this)
      })
      this.panel.addEvent("click", function(e) {
        var target = $(e.target)
           action = target.get("data-slide_command")
        if (!(action in this.commands)) return
        this.slide[action]()
        e.stop()
      }.bind(this))
    }
  , hide: function() {
      this.panel.fade("out")
    }
  , show: function() {
      this.panel.fade("in")
    }
  , commands: (function() {
      var set = {}
      "proceedAndPlay pause next prev showThumbList hideThumbList".split(" ").each(function(c) {
        set[c] = true
      })
      return set
    })()
  })
, Item: new Class({
    initialize: function(img) {
      this.normalSize = img.get("data-l")
      this.thumbnail = img.get("src")
      this.originalSize = img.get("data-o")
      this.desc = img.get("data-title")
      this.lightBoxInfo = img.get("data-slb")
    }
  , toElement: function() {
      return new Element("div").adopt(
        new Element("a").adopt(
          new Element("img", { src: this.normalSize })
        ).set({
          "rel": this.lightBoxInfo
        , "href": this.originalSize
        , "target": "_blank"
        , "title": this.desc
        })
      ).addClass("slide_item")
    }
  })
, instances: []
, busyIndicator: "/images/spinner.gif"
}

document.addEvent("domready", function() {
  var template = $("slide_for_kite")
    , slides = $$(".pics_multi .photos, .photo_set .photos")
  slides.each(function(list) {
    var items = list.getElements("img")
    if (!items.length) return
    var slide = new K.Slide.Stage({
      images: items
    , width: 500
    })
    K.Slide.instances.push(slide)
    list.addEvent("click", function Self() {
      this.removeEvent("click", Self)
      var context = template.clone().replaces(this)
        , controlPanel = context.getElement(".slide_control")
        , controller = new K.Slide.Controller(controlPanel)
      slide.show(context)
      controller.control(slide)
    }).setStyle("cursor", "pointer")
  })
  new Image().src = K.Slide.busyIndicator
})

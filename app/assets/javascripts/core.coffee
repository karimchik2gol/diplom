###*
# @plugin
# @name Core
# @description Formstone Library core. Required for all plugins.
###

### global define ###

### global ga ###

((factory) ->
  if typeof define == 'function' and define.amd
    define [ 'jquery' ], factory
  else
    factory jQuery
  return
) ($) ->
  # Namespace Properties

  namespaceProperties = (type, namespace, globalProps, customProps) ->
    _props = raw: {}
    i = undefined
    customProps = customProps or {}
    for i of customProps
      `i = i`
      if customProps.hasOwnProperty(i)
        if type == 'classes'
          # Custom classes
          _props.raw[customProps[i]] = namespace + '-' + customProps[i]
          _props[customProps[i]] = '.' + namespace + '-' + customProps[i]
        else
          # Custom events
          _props.raw[i] = customProps[i]
          _props[i] = customProps[i] + '.' + namespace
    for i of globalProps
      `i = i`
      if globalProps.hasOwnProperty(i)
        if type == 'classes'
          # Global classes
          _props.raw[i] = globalProps[i].replace(/{ns}/g, namespace)
          _props[i] = globalProps[i].replace(/{ns}/g, '.' + namespace)
        else
          # Global events
          _props.raw[i] = globalProps[i].replace(/.{ns}/g, '')
          _props[i] = globalProps[i].replace(/{ns}/g, namespace)
    _props

  # Set Browser Prefixes

  setBrowserPrefixes = ->
    transitionEvents = 
      'WebkitTransition': 'webkitTransitionEnd'
      'MozTransition': 'transitionend'
      'OTransition': 'otransitionend'
      'transition': 'transitionend'
    transitionProperties = [
      'transition'
      '-webkit-transition'
    ]
    transformProperties = 
      'transform': 'transform'
      'MozTransform': '-moz-transform'
      'OTransform': '-o-transform'
      'msTransform': '-ms-transform'
      'webkitTransform': '-webkit-transform'
    transitionEvent = 'transitionend'
    transitionProperty = ''
    transformProperty = ''
    testDiv = document.createElement('div')
    i = undefined
    for i of transitionEvents
      `i = i`
      if transitionEvents.hasOwnProperty(i) and i of testDiv.style
        transitionEvent = transitionEvents[i]
        Formstone.support.transition = true
        break
    Events.transitionEnd = transitionEvent + '.{ns}'
    for i of transitionProperties
      `i = i`
      if transitionProperties.hasOwnProperty(i) and transitionProperties[i] of testDiv.style
        transitionProperty = transitionProperties[i]
        break
    Formstone.transition = transitionProperty
    for i of transformProperties
      `i = i`
      if transformProperties.hasOwnProperty(i) and transformProperties[i] of testDiv.style
        Formstone.support.transform = true
        transformProperty = transformProperties[i]
        break
    Formstone.transform = transformProperty
    return

  # Window resize

  onWindowResize = ->
    Formstone.windowWidth = Formstone.$window.width()
    Formstone.windowHeight = Formstone.$window.height()
    ResizeTimer = Functions.startTimer(ResizeTimer, Debounce, handleWindowResize)
    return

  handleWindowResize = ->
    for i of Formstone.ResizeHandlers
      if Formstone.ResizeHandlers.hasOwnProperty(i)
        Formstone.ResizeHandlers[i].callback.call window, Formstone.windowWidth, Formstone.windowHeight
    return

  # RAF

  handleRAF = ->
    if Formstone.support.raf
      Formstone.window.requestAnimationFrame handleRAF
      for i of Formstone.RAFHandlers
        if Formstone.RAFHandlers.hasOwnProperty(i)
          Formstone.RAFHandlers[i].callback.call window
    return

  # Sort Priority

  sortPriority = (a, b) ->
    parseInt(a.priority) - parseInt(b.priority)

  'use strict'
  # Namespace
  Win = if typeof window != 'undefined' then window else this
  Doc = Win.document

  Core = ->
    @Version = '@version'
    @Plugins = {}
    @DontConflict = false
    @Conflicts = fn: {}
    @ResizeHandlers = []
    @RAFHandlers = []
    # Globals
    @window = Win
    @$window = $(Win)
    @document = Doc
    @$document = $(Doc)
    @$body = null
    @windowWidth = 0
    @windowHeight = 0
    @fallbackWidth = 1024
    @fallbackHeight = 768
    @userAgent = window.navigator.userAgent or window.navigator.vendor or window.opera
    @isFirefox = /Firefox/i.test(@userAgent)
    @isChrome = /Chrome/i.test(@userAgent)
    @isSafari = /Safari/i.test(@userAgent) and !@isChrome
    @isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(@userAgent)
    @isIEMobile = /IEMobile/i.test(@userAgent)
    @isFirefoxMobile = @isFirefox and @isMobile
    @transform = null
    @transition = null
    @support =
      file: ! !(window.File and window.FileList and window.FileReader)
      history: ! !(window.history and window.history.pushState and window.history.replaceState)
      matchMedia: ! !(window.matchMedia or window.msMatchMedia)
      pointer: ! !window.PointerEvent
      raf: ! !(window.requestAnimationFrame and window.cancelAnimationFrame)
      touch: ! !('ontouchstart' of window or window.DocumentTouch and document instanceof window.DocumentTouch)
      transition: false
      transform: false
    return

  Functions = 
    killEvent: (e, immediate) ->
      try
        e.preventDefault()
        e.stopPropagation()
        if immediate
          e.stopImmediatePropagation()
      catch error
        #
      return
    killGesture: (e) ->
      try
        e.preventDefault()
      catch error
        #
      return
    lockViewport: (plugin_namespace) ->
      ViewportLocks[plugin_namespace] = true
      if !$.isEmptyObject(ViewportLocks) and !ViewportLocked
        if $ViewportMeta.length
          $ViewportMeta.attr 'content', ViewportMetaLocked
        else
          $ViewportMeta = $('head').append('<meta name="viewport" content="' + ViewportMetaLocked + '">')
        Formstone.$body.on(Events.gestureChange, Functions.killGesture).on(Events.gestureStart, Functions.killGesture).on Events.gestureEnd, Functions.killGesture
        ViewportLocked = true
      return
    unlockViewport: (plugin_namespace) ->
      if $.type(ViewportLocks[plugin_namespace]) != 'undefined'
        delete ViewportLocks[plugin_namespace]
      if $.isEmptyObject(ViewportLocks) and ViewportLocked
        if $ViewportMeta.length
          if ViewportMetaOriginal
            $ViewportMeta.attr 'content', ViewportMetaOriginal
          else
            $ViewportMeta.remove()
        Formstone.$body.off(Events.gestureChange).off(Events.gestureStart).off Events.gestureEnd
        ViewportLocked = false
      return
    startTimer: (timer, time, callback, interval) ->
      Functions.clearTimer timer
      if interval then setInterval(callback, time) else setTimeout(callback, time)
    clearTimer: (timer, interval) ->
      if timer
        if interval
          clearInterval timer
        else
          clearTimeout timer
        timer = null
      return
    sortAsc: (a, b) ->
      parseInt(a, 10) - parseInt(b, 10)
    sortDesc: (a, b) ->
      parseInt(b, 10) - parseInt(a, 10)
    decodeEntities: (string) ->
      # http://stackoverflow.com/a/1395954
      el = Formstone.document.createElement('textarea')
      el.innerHTML = string
      el.value
    parseQueryString: (url) ->
      params = {}
      parts = url.slice(url.indexOf('?') + 1).split('&')
      i = 0
      while i < parts.length
        part = parts[i].split('=')
        params[part[0]] = part[1]
        i++
      params
  Formstone = new Core
  $Ready = $.Deferred()
  Classes = 
    base: '{ns}'
    element: '{ns}-element'
  Events = 
    namespace: '.{ns}'
    beforeUnload: 'beforeunload.{ns}'
    blur: 'blur.{ns}'
    change: 'change.{ns}'
    click: 'click.{ns}'
    dblClick: 'dblclick.{ns}'
    drag: 'drag.{ns}'
    dragEnd: 'dragend.{ns}'
    dragEnter: 'dragenter.{ns}'
    dragLeave: 'dragleave.{ns}'
    dragOver: 'dragover.{ns}'
    dragStart: 'dragstart.{ns}'
    drop: 'drop.{ns}'
    error: 'error.{ns}'
    focus: 'focus.{ns}'
    focusIn: 'focusin.{ns}'
    focusOut: 'focusout.{ns}'
    gestureChange: 'gesturechange.{ns}'
    gestureStart: 'gesturestart.{ns}'
    gestureEnd: 'gestureend.{ns}'
    input: 'input.{ns}'
    keyDown: 'keydown.{ns}'
    keyPress: 'keypress.{ns}'
    keyUp: 'keyup.{ns}'
    load: 'load.{ns}'
    mouseDown: 'mousedown.{ns}'
    mouseEnter: 'mouseenter.{ns}'
    mouseLeave: 'mouseleave.{ns}'
    mouseMove: 'mousemove.{ns}'
    mouseOut: 'mouseout.{ns}'
    mouseOver: 'mouseover.{ns}'
    mouseUp: 'mouseup.{ns}'
    panStart: 'panstart.{ns}'
    pan: 'pan.{ns}'
    panEnd: 'panend.{ns}'
    resize: 'resize.{ns}'
    scaleStart: 'scalestart.{ns}'
    scaleEnd: 'scaleend.{ns}'
    scale: 'scale.{ns}'
    scroll: 'scroll.{ns}'
    select: 'select.{ns}'
    swipe: 'swipe.{ns}'
    touchCancel: 'touchcancel.{ns}'
    touchEnd: 'touchend.{ns}'
    touchLeave: 'touchleave.{ns}'
    touchMove: 'touchmove.{ns}'
    touchStart: 'touchstart.{ns}'
  ResizeTimer = null
  Debounce = 20
  $ViewportMeta = undefined
  ViewportMetaOriginal = undefined
  ViewportMetaLocked = undefined
  ViewportLocks = []
  ViewportLocked = false

  ###*
  # @method
  # @name NoConflict
  # @description Resolves plugin namespace conflicts
  # @example Formstone.NoConflict();
  ###

  Core::NoConflict = ->
    Formstone.DontConflict = true
    for i of Formstone.Plugins
      if Formstone.Plugins.hasOwnProperty(i)
        $[i] = Formstone.Conflicts[i]
        $.fn[i] = Formstone.Conflicts.fn[i]
    return

  ###*
  # @method
  # @name Ready
  # @description Replacement for jQuery ready
  # @param e [object] "Event data"
  ###

  Core::Ready = (fn) ->
    if Formstone.document.readyState == 'complete' or Formstone.document.readyState != 'loading' and !Formstone.document.documentElement.doScroll
      fn()
    else
      Formstone.document.addEventListener 'DOMContentLoaded', fn
    return

  ###*
  # @method
  # @name Plugin
  # @description Builds a plugin and registers it with jQuery.
  # @param namespace [string] "Plugin namespace"
  # @param settings [object] "Plugin settings"
  # @return [object] "Plugin properties. Includes `defaults`, `classes`, `events`, `functions`, `methods` and `utilities` keys"
  # @example Formstone.Plugin("namespace", { ... });
  ###

  Core::Plugin = (namespace, settings) ->
    Formstone.Plugins[namespace] = do (namespace, settings) ->
      namespaceDash = 'fs-' + namespace
      namespaceDot = 'fs.' + namespace
      namespaceClean = 'fs' + namespace.replace(/(^|\s)([a-z])/g, (m, p1, p2) ->
        p1 + p2.toUpperCase()
      )
      # Locals

      ###*
      # @method private
      # @name initialize
      # @description Creates plugin instance by adding base classname, creating data and scoping a _construct call.
      # @param options [object] <{}> "Instance options"
      ###

      initialize = (options) ->
        # Maintain Chain
        hasOptions = $.type(options) == 'object'
        args = Array::slice.call(arguments, if hasOptions then 1 else 0)
        $targets = this
        $postTargets = $()
        $element = undefined
        i = undefined
        count = undefined
        # Extend Defaults
        options = $.extend(true, {}, settings.defaults or {}, if hasOptions then options else {})
        # All targets
        i = 0
        count = $targets.length
        while i < count
          $element = $targets.eq(i)
          # Gaurd Against Exiting Instances
          if !getData($element)
            # Extend w/ Local Options
            settings.guid++
            guid = '__' + settings.guid
            rawGuid = settings.classes.raw.base + guid
            locals = $element.data(namespace + '-options')
            data = $.extend(true, {
              $el: $element
              guid: guid
              numGuid: settings.guid
              rawGuid: rawGuid
              dotGuid: '.' + rawGuid
            }, options, if $.type(locals) == 'object' then locals else {})
            # Cache Instance
            $element.addClass(settings.classes.raw.element).data namespaceClean, data
            # Constructor
            settings.methods._construct.apply $element, [ data ].concat(args)
            # Post Constructor
            $postTargets = $postTargets.add($element)
          i++
        # Post targets
        i = 0
        count = $postTargets.length
        while i < count
          $element = $postTargets.eq(i)
          # Post Constructor
          settings.methods._postConstruct.apply $element, [ getData($element) ]
          i++
        $targets

      ###*
      # @method private
      # @name destroy
      # @description Removes plugin instance by scoping a _destruct call, and removing the base classname and data.
      # @param data [object] <{}> "Instance data"
      ###

      ###*
      # @method widget
      # @name destroy
      # @description Removes plugin instance.
      # @example $(".target").{ns}("destroy");
      ###

      destroy = (data) ->
        settings.functions.iterate.apply this, [ settings.methods._destruct ].concat(Array::slice.call(arguments, 1))
        @removeClass(settings.classes.raw.element).removeData namespaceClean
        return

      ###*
      # @method private
      # @name getData
      # @description Creates class selector from text.
      # @param $element [jQuery] "Target jQuery object"
      # @return [object] "Instance data"
      ###

      getData = ($el) ->
        $el.data namespaceClean

      ###*
      # @method private
      # @name delegateWidget
      # @description Delegates public methods.
      # @param method [string] "Method to execute"
      # @return [jQuery] "jQuery object"
      ###

      delegateWidget = (method) ->
        # If jQuery object
        if this instanceof $
          _method = settings.methods[method]
          # Public method OR false
          if $.type(method) == 'object' or !method
            # Initialize
            return initialize.apply(this, arguments)
          else if _method and method.indexOf('_') != 0
            # Wrap Public Methods
            args = [ _method ].concat(Array::slice.call(arguments, 1))
            return settings.functions.iterate.apply(this, args)
          return this
        return

      ###*
      # @method private
      # @name delegateUtility
      # @description Delegates utility methods.
      # @param method [string] "Method to execute"
      ###

      delegateUtility = (method) ->
        # public utility OR utility init OR false
        _method = settings.utilities[method] or settings.utilities._initialize or false
        if _method
          # Wrap Utility Methods
          args = Array::slice.call(arguments, if $.type(method) == 'object' then 0 else 1)
          return _method.apply(window, args)
        return

      ###*
      # @method utility
      # @name defaults
      # @description Extends plugin default settings; effects instances created hereafter.
      # @param options [object] <{}> "New plugin defaults"
      # @example $.{ns}("defaults", { ... });
      ###

      defaults = (options) ->
        settings.defaults = $.extend(true, settings.defaults, options or {})
        return

      ###*
      # @method private
      # @name iterate
      # @description Loops scoped function calls over jQuery object with instance data as first parameter.
      # @param func [function] "Function to execute"
      # @return [jQuery] "jQuery object"
      ###

      iterate = (fn) ->
        $targets = this
        args = Array::slice.call(arguments, 1)
        i = 0
        count = $targets.length
        while i < count
          $element = $targets.eq(i)
          data = getData($element) or {}
          if $.type(data.$el) != 'undefined'
            fn.apply $element, [ data ].concat(args)
          i++
        $targets

      settings.initialized = false
      settings.priority = settings.priority or 10
      # Namespace Classes & Events
      settings.classes = namespaceProperties('classes', namespaceDash, Classes, settings.classes)
      settings.events = namespaceProperties('events', namespace, Events, settings.events)
      # Extend Functions
      settings.functions = $.extend({
        getData: getData
        iterate: iterate
      }, Functions, settings.functions)
      # Extend Methods
      settings.methods = $.extend(true, {
        _construct: $.noop
        _postConstruct: $.noop
        _destruct: $.noop
        _resize: false
        destroy: destroy
      }, settings.methods)
      # Extend Utilities
      settings.utilities = $.extend(true, {
        _initialize: false
        _delegate: false
        defaults: defaults
      }, settings.utilities)
      # Register Plugin
      # Widget
      if settings.widget
        # Store conflicting namesapaces
        Formstone.Conflicts.fn[namespace] = $.fn[namespace]
        # Widget Delegation: $(".target").fsPlugin("method", ...);
        $.fn[namespaceClean] = delegateWidget
        if !Formstone.DontConflict
          # $(".target").plugin("method", ...);
          $.fn[namespace] = $.fn[namespaceClean]
      # Utility
      Formstone.Conflicts[namespace] = $[namespace]
      # Utility Delegation: $.fsPlugin("method", ... );
      $[namespaceClean] = settings.utilities._delegate or delegateUtility
      if !Formstone.DontConflict
        # $.plugin("method", ... );
        $[namespace] = $[namespaceClean]
      # Run Setup
      settings.namespace = namespace
      settings.namespaceClean = namespaceClean
      settings.guid = 0
      # Resize handler
      if settings.methods._resize
        Formstone.ResizeHandlers.push
          namespace: namespace
          priority: settings.priority
          callback: settings.methods._resize
        # Sort handlers on push
        Formstone.ResizeHandlers.sort sortPriority
      # RAF handler
      if settings.methods._raf
        Formstone.RAFHandlers.push
          namespace: namespace
          priority: settings.priority
          callback: settings.methods._raf
        # Sort handlers on push
        Formstone.RAFHandlers.sort sortPriority
      settings
    Formstone.Plugins[namespace]

  Formstone.$window.on 'resize.fs', onWindowResize
  onWindowResize()
  handleRAF()
  # Document Ready
  Formstone.Ready ->
    Formstone.$body = $('body')
    $('html').addClass if Formstone.support.touch then 'touchevents' else 'no-touchevents'
    # Viewport
    $ViewportMeta = $('meta[name="viewport"]')
    ViewportMetaOriginal = if $ViewportMeta.length then $ViewportMeta.attr('content') else false
    ViewportMetaLocked = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'
    $Ready.resolve()
    return
  # Custom Events
  Events.clickTouchStart = Events.click + ' ' + Events.touchStart
  # Browser Prefixes
  setBrowserPrefixes()
  window.Formstone = Formstone
  Formstone

# ---
# generated by js2coffee 2.2.0
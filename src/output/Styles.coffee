class Styles
  @Matrix: require('../../vendor/gl-matrix.js')

  constructor: (@engine) -> 

  # Receive solved styles
  read: (data) ->
    @lastInput = JSON.parse JSON.stringify data

    intrinsic = null

    # Step 1: Filter out measurements 
    for path, value of data
      index = path.indexOf('[intrinsic-')
      if index > -1
        property = path.substring(index + 1, path.length - 1)
        data[prop] = undefined
        (intrinsic ||= {})[path] = value

    @write(@lastInput)

    # Step 2: Apply changed styles in batch, 
    # leave out positioning properties (Restyle/Reflow)
    positioning = {}
    for path, value of data
      @set(path, undefined, value, positioning)

    # Step 3: Adjust positioning styles to respect 
    # element offsets 
    @render(positioning)

    # Step 4: Set new positions in bulk (Restyle)
    for id, styles of positioning
      for prop, value of styles
        @set id, prop, value

    # Step 5: Re-measure elements (Reflow)
    if intrinsic
      for path, value of intrinsic
        @set(path, undefined, value, positioning, true)
    else
      @engine.triggerEvent('solved', data, intrinsic)

  write: (data) ->
    @engine.merge(data)

  remove: (id) ->
    delete @[id]

  camelize: (string) ->
    return (@camelized ||= {})[string] ||= 
      string.toLowerCase().replace /-([a-z])/i, (match) ->
        return match[1].toUpperCase()

  dasherize: (string) ->
    return (@dasherized ||= {})[string] ||= 
      string.replace /[A-Z]/, (match) ->
        return '-' + match[0].toLowerCase()

  get: (path, property, value) ->
    element = @references.get(path)
    camel = @camelize(property)
    style = element.style
    value = style[camel]
    if value != undefined
      return value
    @

  set: (path, property, value, positioning, intrinsic) ->
    if property == undefined
      last = path.lastIndexOf('[')
      property = path.substring(last + 1, path.length - 1)
      path = path.substring(0, last)

    return unless element = @engine.references.get(path)
    positioner = this.positioners[property]
    if positioning && positioner
      (positioning[path] ||= {})[property] = value
    else
      if intrinsic
        result = @engine.context['[' + property + ']'](element)
        if result != value

        else



      if positioner
        positioned = positioner(element)
        if typeof positioned == 'string'
          property = positioned
      camel = @camelize(property)
      style = element.style
      if style[camel] != undefined
        if typeof value == 'number' && property != 'zIndex'
          value += 'px'
        style[camel] = value
    @

  # Position 
  render: (positioning, parent, x, y, offsetParent) ->
    parent = @engine.scope unless parent
    # Calculate new offsets for given element and styles
    if offsets = @preposition(positioning, parent, x, y)
      x += offsets.left
      y += offsets.top

    # Select all children
    children = @engine.context['>'][1](parent);

    # When rendering a positioned element, measure its offsets
    if offsetParent && !offsets && children.length && children[0].parentOffset == parent
      x += parent.offsetLeft
      y += parent.offsetTop
      offsetParent = parent

    # Position children
    for child in children
      @render(positioning, child, x, y, offsetParent)

  # Calculate offsets according to new values (but dont set anything)
  preposition: (positioning, element, x, y) ->
    if uid = element._gss_id
      if styles = positioning[uid]
        offsets = {left: 0, top: 0}
        for property, value of styles
          unless value == null
            switch property
              when "x"
                styles.x = value - (x || 0)
                offsets.left = value - (x || 0)
              when "y"
                styles.y = value - (y || 0)
                offsets.top = value - (y || 0)

    return offsets

  matrix: (positioning, element) ->
    
  positioners:
    x: -> 'left'
    y: -> 'top'
    
module.exports = Styles
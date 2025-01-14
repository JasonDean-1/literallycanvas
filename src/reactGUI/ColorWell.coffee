React = require './React-shim'
{classSet} = require '../core/util'


ColorWell = React.createClass
  displayName: 'ColorWell'
  getState: -> {
    color: @props.lc.colors[@props.colorName],
    isPickerVisible: false
  }
  getInitialState: -> @getState()

  # our color state tracks lc's
  componentDidMount: ->
    @unsubscribe = @props.lc.on "#{@props.colorName}ColorChange", =>
      @setState {color: @props.lc.colors[@props.colorName]}
  componentWillUnmount: -> @unsubscribe()

  togglePicker: -> @setState {isPickerVisible: not @state.isPickerVisible}
  closePicker: -> @setState {isPickerVisible: false}
  setColor: (c) -> @props.lc.setColor(@props.colorName, c)

  render: ->
    {div, label, br} = React.DOM
    (div \
      {
        className: classSet({
          'color-well': true,
          'open': @state.isPickerVisible ,
        }),
        onMouseLeave: @closePicker
        onClick: @togglePicker
        style: {float: 'left', textAlign: 'center'}
      },
      (label {float: 'left'}, @props.label),
      (br {}),
      (div \
        {
          className: classSet
            'color-well-color-container': true
            'selected': @state.isPickerVisible
          style: {backgroundColor: 'white'}
        },
        (div {className: 'color-well-checker color-well-checker-top-left'}),
        (div {
          className: 'color-well-checker color-well-checker-bottom-right',
          style: {left: '50%', top: '50%'}
        }),
        (div \
          {
            className: 'color-well-color',
            style: {backgroundColor: @state.color}
          },
          " "
        ),
      ),
      @renderPicker()
    )

  renderPicker: ->
    {div} = React.DOM
    return null unless @state.isPickerVisible

    renderTransparentCell = =>
      (div \
        {className: 'color-row', key: 0, style: {height: 20}},
        (div \
          {
            className: classSet(
              'color-cell transparent-cell': true,
              'selected': @state.color == 'transparent'
            )
            onClick: => @setColor('transparent')
          },
          'transparent'
        )
      )

    rows = []
    rows.push 'transparent'
    rows.push ("hsl(0, 0%, #{i}%)" for i in [0..100] by 10)
    for hue in [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330]
      rows.push("hsl(#{hue}, 100%, #{i}%)" for i in [10..90] by 8)

    (div {className: 'color-picker-popup'},
      rows.map((row, ix) =>
        return renderTransparentCell() if row == 'transparent'
        return (div \
          {className: 'color-row', key: ix, style: {width: 20 * row.length}},
          row.map((cellColor, ix2) =>
            className = classSet
              'color-cell': true
              'selected': @state.color == cellColor
            (div \
              {
                className,
                onClick: => @setColor(cellColor)
                style: {backgroundColor: cellColor}
                key: ix2
              }
            )
          )
        )
      )
    )


module.exports = ColorWell
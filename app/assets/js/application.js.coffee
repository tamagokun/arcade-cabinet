jQuery(document).ready ($) ->

  wheel = null
  repeat_timeout = 0

  $.ajax '/list',
    success: (data)->
      wheel = new Wheel($("ul"), data)

  $(window).on 'keydown', (e) -> Key.on_down(e)
  $(window).on 'keyup', (e) ->
    Key.on_up(e)
    repeat_timeout = 0

  window.setInterval ->
    return unless wheel
    return if wheel.in_game
    return if new Date().getTime() < repeat_timeout
    if Key.pressed(Key.UP)
      wheel.index-- if wheel.index > 0
      wheel.update()
      if repeat_timeout == 0
        repeat_timeout = new Date().getTime() + 1000
      return
    if Key.pressed(Key.DOWN)
      wheel.index++ if wheel.index < wheel.size
      wheel.update()
      if repeat_timeout == 0
        repeat_timeout = new Date().getTime() + 1000
      return
    if Key.pressed(Key.ENTER)
      wheel.run()
      return
  , 75

class Wheel
  constructor: (@ul, @list) ->
    @view = new infinity.ListView @ul,
      lazy: ->
        $(this).find('li img').each ->
          $ref = $(this)
          $ref.attr('src', $ref.attr('data-original'))
    @index = @list.length / 2
    @page = 1
    @offset = 0
    @size = @list.length
    @height = 75
    @page_size = 50
    @in_game = false
    @init()

  init: ->
    @add i for i in [0..@size-1]
    @update()

  add: (index) ->
    if index < 0 or index > @size
      index = @size - index
    html = if @list[index].image is true then "<img data-original=\"/img/wheels/#{@list[index].name}.png\" />" else @list[index].name
    @view.append("<li id=\"g-#{index}\">#{html}</li>")

  run: ->
    @in_game = true
    game = @list[@index].name
    $.ajax '/launch',
      type: "POST",
      data: { game: game }
    .done =>
      @in_game = false

  update: ->
    $("li",@ul).removeClass("active")
    active = $("#g-#{@index}")
    active.addClass("active")
    index = @index
    $("li",@ul).each ->
      id = $(this).attr('id').split('g-').pop()
      diff = (index - id)
      $(this).css
        transform: "rotate(#{diff * -4}deg)",
        marginLeft: Math.abs(diff) * -15
    window.scrollTo(0, @index * @height - (document.documentElement.clientHeight*.5) + (@height*2))


class Key
  @pressing: {}
  @LEFT: 37
  @UP: 38
  @RIGHT: 39
  @DOWN: 40
  @ENTER: 13
  @pressed: (keyCode) ->
    Key.pressing[keyCode]
  @on_down: (event) ->
    Key.pressing[event.keyCode] = true
  @on_up: (event) ->
    delete Key.pressing[event.keyCode]

jQuery(document).ready ($) ->

  wheel = new Wheel($("ul"))

  #$("ul li span.image").appear ->
    #$(this).replaceWith "<img src=\"#{$(this).text()}\" />"

  $(window).on 'keydown', (e) -> Key.on_down(e)
  $(window).on 'keyup', (e) -> Key.on_up(e)
  window.setInterval ->
    if Key.pressed(Key.UP)
      wheel.index-- if wheel.index > 0
      wheel.update()
      return
    if Key.pressed(Key.DOWN)
      wheel.index++ if wheel.index < wheel.size
      wheel.update()
      return
  , 10


class Wheel
  constructor: (@ul) ->
    @list = new infinity.ListView(@ul)
    @index = 0
    @page = 1
    @size = $("li",@ul).size()
    @height = 50
    @update()

  update: ->
    $("li",@ul).removeClass("active").eq(@index).addClass("active")
    window.scrollTo(0,0)
    @ul.css top: @index * -@height + (document.documentElement.clientHeight*.5) - (@height*.5)


class Key
  @pressing: {}
  @LEFT: 37
  @UP: 38
  @RIGHT: 39
  @DOWN: 40
  @pressed: (keyCode) ->
    Key.pressing[keyCode]
  @on_down: (event) ->
    Key.pressing[event.keyCode] = true
  @on_up: (event) ->
    delete Key.pressing[event.keyCode]

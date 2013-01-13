jQuery(document).ready ($) ->

  $list = new infinity.ListView($("ul"), {
    lazy: ->
      console.log("lazy loaded...")
  })

  index = 0
  page = 1
  size = $("ul li").size()
  update = ->
    $("ul li").removeClass("active").eq(index).addClass("active")
    offset = index * -50
    $("ul").css top: offset + (document.documentElement.clientHeight / 2) - 25
    window.scrollTo(0, 0)

  #$("ul li span.image").appear ->
    #$(this).replaceWith "<img src=\"#{$(this).text()}\" />"

  $(window).on 'keydown', (e) -> Key.on_down(e)
  $(window).on 'keyup', (e) -> Key.on_up(e)
  window.setInterval ->
    if Key.pressed(Key.UP)
      index-- if index > 0
      update()
      return
    if Key.pressed(Key.DOWN)
      index++ if index < size
      update()
      return
  , 10


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

'use strict'

# node libs
fs = require 'fs'
sys = require 'sys'
{exec} = require 'child_process'
gui = require 'nw.gui'

# dependencies
yaml = require 'js-yaml'
{parseString} = require 'xml2js'

app = null
wheel = null

jQuery(document).ready ($) ->

  repeat_timeout = 0

  # go, go go
  app = new App
  app.load_known_games()
  wheel = new Wheel $("ul"), app.games

  $(window).on 'keydown', (e) -> Key.on_down(e)
  $(window).on 'keyup', (e) ->
    Key.on_up(e)
    repeat_timeout = 0

  window.setInterval ->
    return unless wheel
    return if wheel.in_game
    return if new Date().getTime() < repeat_timeout
    # Exit dialog controls
    if app.context == "exit_dialog"
      if Key.pressed(Key.LEFT) || Key.pressed(Key.RIGHT) || Key.pressed(Key.UP) || Key.pressed(Key.DOWN)
        $("#exit-dialog .active").removeClass("active").siblings("a").addClass("active")
        if repeat_timeout == 0
          repeat_timeout = new Date().getTime() + 1000
        return
      if Key.pressed(Key.ENTER) || Key.pressed(Key.P1START) || Key.pressed(Key.P2START)
        $("#exit-dialog .active").click()
        if repeat_timeout == 0
          repeat_timeout = new Date().getTime() + 1000
        return

    # Wheel context controls
    if app.context == "wheel"
      if Key.pressed(Key.UP)
        wheel.turn if wheel.index == 0 then wheel.size - 1 else wheel.index - 1
        if repeat_timeout == 0
          repeat_timeout = new Date().getTime() + 1000
        return
      if Key.pressed(Key.DOWN)
        wheel.turn if wheel.index == wheel.size - 1 then 0 else wheel.index + 1
        if repeat_timeout == 0
          repeat_timeout = new Date().getTime() + 1000
        return
      if Key.pressed(Key.ENTER) || Key.pressed(Key.P1START) || Key.pressed(Key.P2START)
        wheel.run() if !wheel.in_game
        return
      if Key.pressed(Key.ESCAPE)
        app.exit_dialog()
        return
  , 75

class App
  constructor: ->
    # store window
    @window = gui.Window.get()

    # load config
    try
      @config = yaml.safeLoad(fs.readFileSync("config/config.yml", "utf8"))
    catch
      @alert "Couldn't find a configuration", ->
        gui.App.quit()

    # set initial app context
    @context = "wheel"

    # set cabinet type for CSS
    $("body").addClass @config.cabinet

    @events()

  alert: (msg, callback = false)->
    $("body").append "<div id='alert' class='modal'>#{msg}</div>"
    setTimeout ->
      $("#alert").remove()
      callback() if callback
    , 2000

  events: ->
    $("#exit-dialog").on "click", ".yes", (e)->
      e.preventDefault()
      gui.App.quit()
      if config.shutdown_on_exit
        cmd = switch process.platform
          when "win32"
            "shutdown -s"
          when "darwin"
            "osascript -e 'tell app \"System Events\" to shut down'"
          when "linux"
            "/sbin/poweroff"
      exec cmd

    $("#exit-dialog").on "click", ".no", (e) =>
      e.preventDefault()
      @exit_dialog()

  load_known_games: ->
    @games = []
    parseString fs.readFileSync("config/#{@config.database}", "utf8"), (err, res) =>
      _.each res.menu.game, (game_data) =>
        @games.push new Game(game_data)

  exit_dialog: ->
    modal = $("#exit-dialog")
    modal.toggleClass "hidden"
    modal.find(".yes").addClass("active")
    modal.find(".no").removeClass("active")
    @context = if modal.is(":visible")
      "exit_dialog"
    else
      "wheel"


class Game
  constructor: (data) ->
    @name = data.$.name
    @description = data.description[0]
    @locate_assets()

  path_if_exists: (path) ->
    return path if fs.existsSync path
    false

  locate_assets: ->
    dir = "#{app.config.themes}/#{@name}"
    @wheel = @path_if_exists "#{dir}/#{@name}.png"
    @background = @path_if_exists "#{dir}/Background.png"
    @artwork = @path_if_exists "#{dir}/Theme.xml"
    @animations = {}

    if app.config.animations && @artwork
      parseString fs.readFileSync(@artwork, "utf8"), (err, res) =>
        return unless res
        _.each res.Theme, (artwork, name) =>
          if /artwork/.test name
            @animations[name] = artwork[0].$


class Wheel
  constructor: (@ul, @list) ->
    @view = new infinity.ListView @ul,
      lazy: ->
        $(this).find('li img').each ->
          $ref = $(this)
          $ref.attr('src', $ref.attr('data-original'))
      SCROLL_THROTTLE: 1
    @index = Math.ceil @list.length / 2
    @page = 1
    @offset = 0
    @size = @list.length
    @height = 75
    @window_height = switch app.config.cabinet
      when "cocktail"
        document.documentElement.clientWidth
      else
        document.documentElement.clientHeight
    @page_size = Math.ceil @window_height / @height
    @in_game = false
    @bg_timeout = 0
    @init()

  init: ->
    @add i, true for i in [@size-@page_size-1..@size-1]
    @add i for i in [0..@size-1]
    @add i, true for i in [0..@page_size-1]
    # set dom height for scrolling maths
    $("html").height @size * @height
    @update()

  add: (index, padded=false) ->
    if index < 0 or index > @size
      index = @size - index
    wheel_image = @list[index].wheel
    html = if wheel_image
      "<img data-original=\"#{wheel_image}\">"
    else
      @list[index].description
    id = if padded then "pad-#{index}" else "g-#{index}"
    @view.append("<li id=\"#{id}\">#{html}</li>")

  run: ->
    @in_game = true
    game = @list[@index].name

    cmd = switch process.platform
      when "win32"
        "#{app.config.launcher.win32} #{game}"
      when "darwin"
        "\"#{app.config.launcher.mac}\" -Game \"#{game}\" -FullScreen YES"
      when "linux"
        "\"#{app.config.launcher.linux}\" \"#{game}\""

    exec cmd, (err, stdout, stderr) =>
      @in_game = false
      Key.clear()
      app.window.show()
      app.window.focus()
      unless err is null
        app.alert "#{err}"

  turn: (index) ->
    @index = index
    @update()
    if app.config.sounds
      sound_id = Math.floor(Math.random() * 124) + 1
      @wheel_sound.unload() if @wheel_sound
      @wheel_sound = new Howl
        urls: ["sounds/wheels/GS#{sound_id}.ogg"]
        autoplay: true
        loop: false
        volume: 0.5

  update_theme: =>
    bg = @list[@index].background || "img/Background.png"
    $("body").css backgroundImage: "url(#{bg})"
    #$("#title").fadeOut 200, ->
      #$(this).css(backgroundImage: "url(#{title})").fadeIn(200)

  update: ->
    window.scrollTo(0, (@index + @page_size + 1) * @height - (@window_height*.5) + @height + 35)
    switch app.config.cabinet
      when "cocktail"
        $("ul").css top: -((@index + @page_size + 1) * @height) - (@window_height*.5) - @height - 25
    @view.scroll_update()
    $("li",@ul).removeClass("active")
    active = $("#g-#{@index}")
    active.addClass("active")
    index = $("li").index(active)
    $("li",@ul).each ->
      id = $("li").index(this)
      diff = (index - id)
      $(this).css
        transform: "rotate(#{diff * -4}deg)",
        marginLeft: Math.abs(diff) * -15
    @bg_timeout = window.setTimeout(@update_theme, 250)


class Key
  @pressing: {}
  @LEFT: 37
  @UP: 38
  @RIGHT: 39
  @DOWN: 40
  @ENTER: 13
  @P1START: 49
  @P2START: 50
  @ESCAPE: 27
  @pressed: (keyCode) ->
    Key.pressing[keyCode]
  @on_down: (event) ->
    Key.pressing[event.keyCode] = true
  @on_up: (event) ->
    delete Key.pressing[event.keyCode]
  @clear: ->
    Key.pressing = {}

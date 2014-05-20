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
  wheel = new Wheel $("ul"), app.games

  $(window).on 'keydown', (e) -> Key.on_down(e)
  $(window).on 'keyup', (e) ->
    Key.on_up(e)
    repeat_timeout = 0

  window.setInterval ->
    return unless wheel
    return if wheel.in_game
    return if new Date().getTime() < repeat_timeout
    if Key.pressed(Key.UP)
      wheel.index = if wheel.index == 0 then wheel.size - 1 else wheel.index - 1
      wheel.update()
      if repeat_timeout == 0
        repeat_timeout = new Date().getTime() + 1000
      return
    if Key.pressed(Key.DOWN)
      wheel.index = if wheel.index == wheel.size - 1 then 0 else wheel.index + 1
      wheel.update()
      if repeat_timeout == 0
        repeat_timeout = new Date().getTime() + 1000
      return
    if Key.pressed(Key.ENTER) || Key.pressed(Key.P1START) || Key.pressed(Key.P2START)
      wheel.run()
      return
  , 75

class App
  constructor: ->
    # store window
    @window = gui.Window.get()

    # load config
    @config = yaml.safeLoad(fs.readFileSync("config/config.yml", "utf8"))
    @load_known_games()

  load_known_games: ->
    @games = []
    parseString fs.readFileSync("config/#{@config.database}", "utf8"), (err, res) =>
      _.each res.menu.game, (game_data) =>
        @games.push new Game(game_data)


class Game
  constructor: (data) ->
    @name = data.$.name
    @description = data.description[0]
    @locate_assets()

  path_if_exists: (path) ->
    return path if fs.existsSync path
    false

  locate_assets: ->
    dir = "assets/themes/#{@name}"
    @wheel = @path_if_exists "#{dir}/#{@game}.png"
    @background = @path_if_exists "#{dir}/Background.png"
    @artwork = @path_if_exists "#{dir}/Theme.xml"
    @animations = {}

    # TODO: Load animations
    # if window.app.config.animations && @artwork
    #   console.log "going to parse"
    #   parseString fs.readFileSync("#{dir}/Theme.xml", "utf8"), (err, res) ->
    #     console.log res
    #      _.each res.theme, (artwork) ->
    #        if artwork.name =~ /artwork/
    #          assets.animations[artwork.name] = artwork.$


class Wheel
  constructor: (@ul, @list) ->
    @view = new infinity.ListView @ul,
      lazy: ->
        $(this).find('li img').each ->
          $ref = $(this)
          $ref.attr('src', $ref.attr('data-original'))
      SCROLL_THROTTLE: 1
    @index = @list.length / 2
    @page = 1
    @offset = 0
    @size = @list.length
    @height = 75
    @page_size = Math.ceil(document.documentElement.clientHeight / @height)
    @in_game = false
    @bg_timeout = 0
    @init()

  init: ->
    @add i, true for i in [@size-@page_size-1..@size-1]
    @add i for i in [0..@size-1]
    @add i, true for i in [0..@page_size-1]
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
        # || osascript -e 'tell application "" to activate'
        "\"#{app.config.launcher.mac}\" -Game \"#{game}\" -FullScreen YES"
      when "linux"
        # || wmctrl -a application
        "\"#{app.config.launcher.linux}\" \"#{game}\""

    exec cmd, (err, stdout, stderr) =>
      @in_game = false
      app.window.show()
      app.window.focus()
      unless err is null
        console.log "exec error: #{err}"

  update_theme: =>
    bg = @list[@index].background || "img/Background.png"
    $("body").css backgroundImage: "url(#{bg})"
    #$("#title").fadeOut 200, ->
      #$(this).css(backgroundImage: "url(#{title})").fadeIn(200)

  update: ->
    window.scrollTo(0, (@index + @page_size + 1) * @height - (document.documentElement.clientHeight*.5) + (@height*2))
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
  @pressed: (keyCode) ->
    Key.pressing[keyCode]
  @on_down: (event) ->
    Key.pressing[event.keyCode] = true
  @on_up: (event) ->
    delete Key.pressing[event.keyCode]

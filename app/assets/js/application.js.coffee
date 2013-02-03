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
		html = if @list[index].wheel is true then "<img data-original=\"/themes/#{@list[index].name}/#{@list[index].name}.png\" />" else @list[index].description
		id = if padded then "pad-#{index}" else "g-#{index}"
		@view.append("<li id=\"#{id}\">#{html}</li>")

	run: ->
		@in_game = true
		game = @list[@index].name
		$.ajax '/launch',
			type: "POST",
			data: { game: game }
		.done =>
			@in_game = false

	update_theme: =>
		bg = if @list[@index].background then "/themes/#{@list[@index].name}/Background.png" else "/img/Background.png"
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
	@pressed: (keyCode) ->
		Key.pressing[keyCode]
	@on_down: (event) ->
		Key.pressing[event.keyCode] = true
	@on_up: (event) ->
		delete Key.pressing[event.keyCode]

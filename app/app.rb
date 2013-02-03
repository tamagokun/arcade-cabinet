module FrontEnd
	class App < Sinatra::Base

		enable :method_override
		dir = File.dirname(File.expand_path(__FILE__))
		set :root, File.expand_path(File.dirname(dir))
		set :public_folder, "#{dir}/public"
		set :views, "#{dir}/views"
		set :static, true

		configure do
			set :config, YAML.load_file("#{settings.root}/config/config.yml")
		end

		def is_ajax_request?
			if respond_to? :content_type
				return true if request.xhr?
			end
			false
		end

		def json_data(data)
			content_type "application/json" if is_ajax_request?
			data.to_json
		end

		def existing_assets(game)
			theme_dir = "#{settings.public_folder}/themes/#{game}"
			assets = {
				:wheel => File.exist?("#{theme_dir}/#{game}.png"),
				:background => File.exist?("#{theme_dir}/Background.png"),
				:artwork => File.exist?("#{theme_dir}/Theme.xml"),
				:animations => Hash.new
			}
			if settings.config[:animations] && assets[:artwork]
				animations = Nokogiri::XML(File.open("#{theme_dir}/Theme.xml"))
				animations.css("Theme").children.each do |artwork|
					if artwork.name =~ /artwork/
						assets[:animations][artwork.name] = Hash[artwork.attributes.to_hash.map{ |k,v| [k, v.value]}]
					end
				end
			end
			assets
		end

		get "/" do
			slim :index
		end

		get "/list" do
			file = File.open("#{settings.root}/config/#{settings.config[:database]}")
			games = []
			db = Nokogiri::XML(file)
			db.css("menu game").each do |game|
				name = game['name']
				description = game.children.at_css("description").text
				games << existing_assets(name).merge({:name => name, :description => description})
			end
			json_data games
		end

		post "/launch" do
			game = params[:game]

			case
			when RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/
				# Windows
			when RUBY_PLATFORM =~ /darwin/
				# Mac OSX
				`"#{settings.config[:launcher][:mac]}" -Game #{game} -FullScreen YES || osascript -e 'tell application "#{settings.config[:application]}" to activate'`
			else
				# Linux
				`"#{settings.config[:launcher][:linux]}" #{game} || wmctrl -a "#{settings.config[:application]}"`
			end

		end

	end
end

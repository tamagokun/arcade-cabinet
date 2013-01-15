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

		get "/" do
			slim :index
		end

		get "/list" do
			file = File.open("#{settings.root}/config/#{settings.config[:database]}")
			games = []
			db = Nokogiri::XML(file)
			db.css("menu game").each do |game|
				name = game.attributes.first.last
				games << {
					:name => name,
					:image => File.exist?("#{settings.public_folder}/img/wheels/#{name}.png")
				}
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
				`"#{settings.config[:launcher]}" -Game #{game} -FullScreen YES || osascript -e 'tell application "#{settings.config[:application]}" to activate'`
			else
				# Linux
				# wmctrl -a Firefox
			end

		end

	end
end

module FrontEnd
	class App < Sinatra::Base

		enable :method_override
		dir = File.dirname(File.expand_path(__FILE__))	
		set :root, File.expand_path(File.dirname(dir))
		set :public_folder, "#{dir}/public"
		set :views, "#{dir}/views"
		set :static, true

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
			file = File.open("#{settings.root}/config/MAME.xml")
			games = []
			db = Nokogiri::XML(file)
			db.css("menu game").each do |game|
				games << game.attributes.first.last
			end
			json_data games
		end

	end
end

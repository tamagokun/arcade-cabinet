module FrontEnd
	class App < Sinatra::Base

		enable :method_override
		dir = File.dirname(File.expand_path(__FILE__))	
		set :root, File.expand_path(File.dirname(dir))
		set :public_folder, "#{dir}/public"
		set :views, "#{dir}/views"
		set :static, true

		get "/" do
			file = File.open("#{settings.root}/config/MAME.xml")
			games = []
			db = Nokogiri::XML(file)
			db.css("menu game").each do |game|
				games << {
					:name => game.attributes.first.last,
				}
			end
			slim :index, :locals => {:games => games }
		end

	end
end

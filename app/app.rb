module FrontEnd
	class App < Sinatra::Base

		enable :method_override
		dir = File.dirname(File.expand_path(__FILE__))	
		set :root, File.expand_path(File.dirname(dir))
		set :public_folder, "#{dir}/public"
		set :views, "#{dir}/views"
		set :static, true

		get "/" do
			slim :index
		end

	end
end

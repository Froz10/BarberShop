#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end	

def seed_db db, barbers

	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (name) values (?)', [barber]
		end	
	end	

end	

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end	

before do
	db = get_db
	@barbers = db.execute 'select * from Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS 
		"Users" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"username" TEXT, 
			"phone" TEXT, 
			"datestamp" TEXT, 
			"barber" TEXT, 
			"color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS 
		"Barbers" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"name" TEXT 
		)'	

	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']	


end

get '/login' do
	erb :login
end

post '/login' do

	@login = params[:login]
	@password = params[:password]
	@title = 'Ha ha, nice try!'
	@message = "Access denide"
	

	if @login == 'admin' && @password == 'secret'
		erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"

	elsif @login == 'admin' && @password == 'admin'
		erb :message

	else
		erb :message
	end

end


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end


get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do

	@username  = params[:username]
	@phone     = params[:phone]
	@datetime  = params[:datetime]
	@barber    = params[:barber]
	@color 	   = params[:color]	

	@title = 'Thank you!'
	@message = "<h2> Спасибо, вы записались!</h2>"

	hh = { :username => 'Введите имя',
	       :phone => 'Введите телефон',
	   	   :datetime => 'Введите дату и время' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :visit
	end

	db = get_db
	db.execute 'insert into 
		Users 
		(
			username, 
			phone, 
			datestamp, 
			barber, 
			color
		)	
		values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]


erb :message

end

get '/contacts' do
	erb :contacts
end

post '/contacts' do

	@email             = params[:email]
	@emailmessage      = params[:emailmessage]


	@title2 = 'Thanks for your contact'
	@message2 = "Your message has been sent to #{@email}"

	f = File.open './public/contacts.txt', 'a'
	f.write "Email: #{@email}, Message: #{@emailmessage}\n"
	f.close

	erb :contacts_post

end

get '/showusers' do
	db = get_db

	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end




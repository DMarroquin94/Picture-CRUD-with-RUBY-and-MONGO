require 'sinatra'
require 'mongo/object'

connection = Mongo::Connection.new
db = connection.default_test
#db.drop

loggedInUser = ""

class User

	include Mongo::Object

	attr_reader :Username, :Password, :Firstname, :Lastname, :Email, :Pictures

	def initialize(username, password, firstname, lastname, email, pictures) 
		@Username = username
		@Password = password
		@FirstName = firstname
		@LastName = lastname
		@Email = email
		@Pictures = pictures
	end

	def getUsername
		@Username
	end

	def getFirstname
		@Firstname
	end

	def getLastname
		@Lastname
	end

	def getPassword
		@Password
	end

	def getEmail
		@Email
	end

	def getPictures
		@Pictures
	end

	def addPicture(pic)
		@Picture.push(pic)
	end

	def setPictures(pics)
		@Pictures = pics
	end

	class Image

		include Mongo::Object

		def initialize(path, title, comment, owner)
			@Path = path
			@Title = title
			@Comment = comment
			@Owner = owner
		end

		def getPath 
			@Path
		end

		def getTitle
			@Title
		end

		def getComment
			@Comment
		end

		def getOwnder 
			@Owner
		end

	end
end

get "/" do 
	erb :home, :locals => {pics: db.pics.all(), loggedInUser: loggedInUser }	
end

get "/login" do 
	
	erb :form, :locals => {loggedInUser: loggedInUser }			
end

post "/signup" do 
	user = User.new(params[:username], params[:password], params[:firstname], params[:lastname], params[:email], Array.new)
	name = user.getUsername

	loggedInUser = name
	db.units.save _id: Time.now.to_s + rand(1000000000).to_s, username: user.getUsername, password: user.getPassword, firstname: user.getFirstname, lastname: user.getLastname, email: user.getEmail #, path: "-", title: "-", comment: "-", type: "user"

	user = db.units.first(username: name)
	redirect "/"
end

post "/login" do
	loggedInUser =  db.units.first(username: params[:username])['username']
	
	redirect "/"
end

get "/logout" do 
	loggedInUser = ""
	redirect "/"
end

get "/:username" do 
	user = db.units.first(username: params[:username])
	pics = db.pics.all(userId: user['username'])
	erb :userPage, :locals => {loggedInUser: loggedInUser , user: user, pics: pics}
end

post "/:username/picture" do 
	name = params[:username]
	title = params[:title]
	comment = params[:comment]

	if (!File.exists?("public/users/" + name))
		Dir.mkdir("public/users/" + name)
	end

	path = "/users/" + name + "/" + params[:picture][:filename]

	user = db.units.first(username: name)

	File.open("public/"+ path, "wb") do |f|
		f.write(params[:picture][:tempfile].read)
	end

	realPath = path#{}"<%= url'(" + path + ")' %>"  
	pic = User::Image.new(path, title, comment, user['username'])

	db.units.save id: user['id'], username: user['username'], password: user['password'], firstname: user['firstname'], lastname: user['Lastname'], email: user['email'] #, path: pic.getPath, title: pic.getTitle, comment: pic.getComment, type: "pic"
	db.pics.save id: Time.now.to_s + rand(1000000000).to_s, userId: user['username'], path: pic.getPath, title: pic.getTitle, comment: pic.getComment, type: "pic"
	
	redirect '/'
end

get '/deletepic/:id' do 
	db.pics.remove(id: params[:id])
	redirect '/'
end
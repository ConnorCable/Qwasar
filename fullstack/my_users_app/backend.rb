require 'sinatra'
require 'sqlite3'
require 'erb'
set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

#URL = http://web-c10603eda-e7b8.docode.us.qwasar.io

db = SQLite3::Database.new "db.sql"

users = db.execute <<-SQL
    create table if not exists users (
        firstname varchar(15),
        lastname varchar(15),
        age int,
        password varchar(30),
        email varchar(30),
        id int
    );
SQL

class User
    @@db = SQLite3::Database.open "db.sql"

    def self.initialize( firstname, lastname, age: 0 , password: 1234, email: "1234@gmail.com")
        @firstname = firstname
        @lastname = lastname
        @age = age
        @password = password
        @email = email
    end

    def self.create(firstname:, lastname:, age: 0 , password: 1234, email: "1234@gmail.com")
       @id = rand(1..1000)
       @@db.execute("INSERT INTO users (firstname, lastname, age, password, email, id)
                    VALUES (?,?,?,?,?,?)", [firstname, lastname, age, password, email, @id])
        return @id
    end

    def self.find(param:, val:)
        results = @@db.query("SELECT * FROM users WHERE #{param}=?", val)
        return results
    end

    def self.find_sanitized(param:, val:)
        results = @@db.query("SELECT firstname, lastname, age, email, id FROM users WHERE #{param}=?", val)
        return results
    end

    def self.user_auth(email:, password:)
        results = @@db.query("SELECT 1 FROM users WHERE email=? AND password=?", email, password)
        return results
    end

    def self.find_id(param:, val:)
        results = @@db.get_first_value("SELECT id FROM users WHERE #{param}=?", val)
        return results
    end

    def self.all()
        results = @@db.query("SELECT * FROM users")
        return results
    end

    def self.update( id:, attribute:, value:)
        @@db.execute("UPDATE users SET #{attribute}=? WHERE id=?", value, id)
    end

    def self.update_password( id:, value:)
        @@db.execute("UPDATE users SET password =? WHERE id=?", value, id)
    end

    def self.updatewithclass(email:, attribute:, value:)
        @@db.execute("UPDATE users SET #{attribute}=? WHERE email=?", value, email)
    end

    def self.destroy(id:)
        @@db.execute("DELETE FROM users WHERE id=?", id)
    end

    
end


User.create(firstname:"Connor", lastname:"Cable", email: "testemailforgaetan")
User.updatewithclass(email:"testemailforgaetan", attribute:"age", value:"34")
puts User.all().each {|row| puts row.join(",")}

get '/' do
    @results = User.all
    erb :index, {:locals => params}
end

get '/users' do
    results = User.all
    results.each{ |row| 
    row.delete_at(3)
    puts row.join(',')}
end

post '/users' do
    @firstname = params["firstname"]
    @lastname = params["lastname"]
    @age = params["age"]
    @password = params["password"]
    @email = params["email"]

    @id = User.create(firstname: @firstname, lastname: @lastname, age: @age, password: @password, email:@email)
    results = User.find_sanitized(param: "id", val: @id)
    results.each{ |row| puts row.join(',')}
end

put '/users' do
    if session[:user_id]
        puts "password changed"
        puts User.update_password(id: session[:user_id], value: params[:password] )
    end
end


post '/sign_in' do
    # input is a hash named params
    # {email: "1234@gmail.com", password:"1234"

    if User.user_auth(email: params["email"], password: params["password"])
        @id = User.find_id(param: "email", val: params["email"])
        if @id
            puts "User Authenticated"
        end
        session[:user_id] = @id
        puts session[:user_id]
        puts "Id logged in? -->"

        redirect "/"
    else
        puts "User login not found"
        redirect "/sign_in"
    end
end

delete '/sign_out' do
    if session[:user_id]
        session.clear
        halt 204
    else
        puts "No user to log out!"
        redirect "/"
    end
end

delete "/users" do
    if session[:user_id]
        User.destroy(id: session[:user_id])
        session.clear
        halt 204
        puts "User deleted!"
    else
        puts "No user to delete!"
        redirect "/"
    end
end

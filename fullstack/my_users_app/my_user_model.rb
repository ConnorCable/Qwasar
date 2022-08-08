require "sqlite3"

$db = SQLite3::Database.new "db.sql"

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

    def initialize(db)
        @@db = db
    end

    def create(firstname: , lastname: , age: ,password: ,email:)
       id = rand(1..100)
       @@db.execute("INSERT INTO users (firstname, lastname, age, password, email, id)
                    VALUES (?,?,?,?,?,?)", [firstname, lastname, age, password, email, id])
        return id
    end

    def find(id:)
        results = @@db.query("SELECT * FROM users WHERE id=?", id)
        return results
        
    end

    def all()
        results = @@db.query("SELECT * FROM users")
        return results
    end

    def update( id:, attribute:, value:)
        @@db.execute("UPDATE users SET #{attribute} = ? WHERE id=?", value, id)
        find(db, id:id)
    end

    def destroy(id:)
        @@db.execute("DELETE FROM users WHERE id=?", id)
    end

    
end

curl -X POST -i localhost:8000/users -d "firstname=Tim" -d "lastname=Hortons" -d "age=60" -d "password=1234" -d "email=2123@gmail.com"
curl POST -i localhost:8000/sign_in -d "email=2123@gmail.com" -d "password=1234" 
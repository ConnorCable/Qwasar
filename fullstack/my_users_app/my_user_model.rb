require "sqlite3"

db = SQLite3::Database.new "db.sql"
db.results_as_hash = true

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
    def create(db, firstname: , lastname: , age: ,password: ,email:)
       id = rand(1..100)
       db.execute("INSERT INTO users (firstname, lastname, age, password, email, id)
                    VALUES (?,?,?,?,?,?)", [firstname, lastname, age, password, email, id])
        return id
    end

    def find(db, id:)
        results = db.query("SELECT * FROM users WHERE id=?", id)
        return results
        
    end

    def all(db)
        results = db.query("SELECT * FROM users")
        return results
    end

    def update(db, id:, attribute:, value:)
        db.execute("UPDATE users SET #{attribute} = ? WHERE id=?", value, id)
        find(db, id:id)
    end

    def destroy(db, id:)
        db.execute("DELETE FROM users WHERE id=?", id)
    end

    
end

user = User.new


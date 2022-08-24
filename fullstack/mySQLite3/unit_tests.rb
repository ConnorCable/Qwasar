require_relative "my_sqlite_request.rb"


=begin
    Select col from data
    Select * from data
    Select col from data where
    Select * from data where
    Select col from data where join data on col1 = col2 
    select col from data where condition order by col asc

    update data where condition

    delete data where condition

    insert data where condition
=end


csvr = MySqliteRequest.new
puts "=============================="
puts "***Select col from data***"
puts "=============================="

csvr.from("data.csv").select("weight").run
puts "=============================="
puts "***Select * from data***"
puts "=============================="
csvr.from("nba_player_data.csv").select("*").where("weight",240).run

puts "=============================="
puts "***Select col from data where condition***"
puts "=============================="
csvr.from("data.csv").select("name", "year_start").where("year_start", 2017).run
puts "=============================="
puts "***Select col from data where join data on col1 = col2***"
puts "=============================="
csvr.from("data.csv").select("*").where("weight",240).join("name","data_to_join.csv","player").run
=begin
puts "=============================="
puts "***select col from data where condition order by col asc***"
puts "=============================="
csvr.from("nba_players.csv").select("*").where("weight", "77").order("name","asc").run
=end




require_relative "req.rb"


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
puts "========================================================================"
puts "SELECT weight FROM data"
puts
csvr.from("data.csv").select("weight").run

puts "========================================================================"
puts "SELECT * FROM nba_player_data WHERE weight = 240"
puts
csvr.from("nba_player_data.csv").select("*").where("weight",240).run

puts "========================================================================"
puts "SELECT name, year_start FROM data WHERE year_start = 2017"
puts
csvr.from("data.csv").select("name", "year_start").where("year_start", 2017).run


puts "========================================================================"
puts "SELECT * FROM data JOIN data_to_join ON name = player WHERE weight = 240"
puts
csvr.from("data.csv").select("*").join("name","data_to_join.csv","player").where("weight",240).run

puts "========================================================================"
puts "SELECT name, player FROM data JOIN data_to_join ON name = player"
puts
csvr.from("data.csv").select("name", "player").join("name","data_to_join.csv","player").run

puts "============================== DELETE BY STRING ========================================="
puts "DELETE FROM data WHERE name = 'Alaa Abdelnaby'"
puts
csvr.delete.from("data.csv").where("name", "Alaa Abdelnaby").run

puts "============================== DELETE BY INT =================================="
puts "DELETE FROM data WHERE year_start = 1969"
puts
csvr.delete.from("data.csv").where("year_start", 1969).run

hash = {:college=>"University of California, Santa Cruz", :name=>"Connor"}
puts "============================== UPDATE BY STRING ============================"
puts "UPDATE data.csv SET college = \"University of California, Santa Cruz\", name = \"Connor\" WHERE name = 'Alex Abrines';"
puts 
csvr.update("data.csv").set(hash).where("name", "Alex Abrines").run

hash = {:college=>"University of California, Santa Cruz", :name=>"Connor"}
puts "============================== UPDATE BY INT ==============================="
puts "UPDATE data.csv SET college = \"University of California, Santa Cruz\", name = \"Connor\" WHERE year_start = 1998;"
puts 
csvr.update("data.csv").set(hash).where("year_start", 1998).run

hash1 = {:name=>"Thanh N", :year_start=>1996, :year_end=>2022, :position=>"F-C", :height=>"5-7", :weight=>140, :birth_date=>"Oct 1, 1996", :college=>"College of Alameda"}
puts "======================= INSERT DATA =================================="
puts "INSERT INTO data.csv VALUES (\"Thanh N\", 1996, 2022, F-C, 5-7, 143, \"Oct 1, 1996\", \"Alameda College\") "
puts 
csvr.insert("data").values(hash1).run
=begin
puts "=============================="
puts "***select col from data where condition order by col asc***"
puts "=============================="
csvr.from("nba_players.csv").select("*").where("weight", "77").order("name","asc").run
=end












        # check if where is set
        # smashing table together if where is not set
=begin
        if (@where_column && @where_criteria)
            # printing out based table only
            csv1.each do |hashA|
                # pushing data from tableA to tableC based on @where_criteria
                csv2.each do |hashB|
                    if (hashA[@where_column.to_sym] == @where_criteria && hashB[@where_column.to_sym] == @where_criteria)
                        # add to tableC
                        joined_table[jIndex] = hashA
                        jIndex+=1
                        break
                    end
                end
            end
        else
            # printing out smashed table
        end
=end



time = Time.new
puts "MySQLite version 0.1 #{time.strftime("%Y/%d/%m")}"
require_relative "req.rb"

class CLI_Interface
    @@csvr = MySqliteRequest.new

    def initialize()
        @cli_input = "" # string
        @input = nil    # array
    end
    
    def get_input()
        # get user input
        @cli_input = gets.chomp

        if @cli_input == "exit"
            puts "exiting program"
            return
        end

        # parse user input
        @input = @cli_input.split
    
        case @input[0]
        when "SELECT" # DONE 
            cli_select()
        when "INSERT"
            cli_insert()
        when "UPDATE"
            cli_update()
        when "DELETE"
            cli_delete()
        else
            puts "Invalid input."
        end
    end

    def cli_select()
    
        column = @input[1]
        table = @input[3]
    
        # validate query
        if (@input[2] != "FROM" || !table)#              0      1       2     3
            puts "No table to select from\n\tSYNTAX: SELECT `column` FROM `table`"
            get_input()
        end
    
        # execute query
        #puts "@@csvr.select(#{column}).from(#{table}).run"
        @@csvr.select(column).from(table).run
        puts
        get_input()
    end
    
    def cli_insert()
        table = @input[2]
        
        # parse values
        values = @cli_input.split("VALUES").last # split @input string into array, get everything right of VALUES
        # gsub(/("[^",]+),([^"]+")/,"")
        # clean up string
        values.tr!("();", "").slice!(0)
        # /(".*?"|[^",\s]+)(?=\s*,|\s*$)/
        # remove commas in input, select everything in double quotes,  split to be parse into hash
        arr = values.split(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/).reject{|elem| elem == ', ' || elem == " " || elem == "" || elem.empty?}
    
        
        # validate query
        if (@input[1] != "INTO")
            puts "Invalid syntax\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
            get_input()
        end
        if (!table)
            puts "No table to selected"
            get_input()
        end
        if (@input[3] != "VALUES" || values.size == 0)
            puts "No values to be insert\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
            get_input()
        end

        
        # THIS -> "Thanh N", 1996, 2022, F-C, 5-7, 143, "Oct 1, 1996", "First college, second college"
        
        @@csvr.insert(table) # initialize headers by using the .insert function, they can be accessed with @@csvr.headers
        newhash = Hash.new
        #
        # the following loop will take all the inputs and map them to a hash with the correct keys
        # The headers are extracted from @@csvr.headers
        # The output -> newhash = {:header1 => value1, :header2 => value2, ...}
        (0...arr.size).each do |i|
            arr[i].gsub!('"',"") # removes the extra pair of quotes from a string
            if Integer(arr[i], exception:false).nil? # can the element NOT be cast as an integer?
                newhash[@@csvr.headers[i]] = arr[i] # if so, just add it to the hash as normal
                next
            end
            newhash[@@csvr.headers[i]] = arr[i].to_i # cast it as an integer, add it to a hash
        end
        # INSERT INTO data.csv VALUES ("Thanh N", 1996, 2022, F-C, 5-7, 143, "Oct 1, 1996", "Alameda College")

        @@csvr.values(newhash).run
        #puts "@@csvr.insert(#{table}).values(#{values})"
        #@@csvr.insert(table).values(newhash)
        puts newhash
        get_input()
    end
    
    def cli_update()
        table = @input[1]

        # validate query
        if (!table)
            puts "No table selected"
            get_input()
        end
        if (@input[2] != "SET")
            puts "No column selected"
            get_input()
        end
        if (!@input.include? "WHERE")
            puts "Require criteria"
            get_input()
        end
    
        # get set values
        set_values = cli_input.split("SET").last.split("WHERE").first # get everything between WHERE and SET
        set_values_arr = set_values.split(",")#
        
        # convert columns new content to hash
        hash = {}
        set_values_arr.each_with_index do |element, index|
            # get key value and clean up 
            str = element.split("=")
            str[0].tr!(" ","")
            key = str[0]
            value = str[1].match(/'.*?'/).to_s
            value.slice!(0)
            value.chop!
            hash[key.to_sym] = value
        end
        
        # get where_column & where_criteria
        where = cli_input.split("WHERE").last
        where = where.split("=")
        where[0].tr!(" ", "")
        where[1] = where[1].match(/'.*?'/).to_s
        where[1].slice!(0)
        where[1].chop!
        
        # execute query
        # UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';
        #puts "@@csvr.update(#{table}).set(#{hash}).where(#{where[0]},#{where[1].class})"
    end
    
    def cli_delete()
        # DELETE FROM students WHERE name = 'John';
        table = @input[2]
    
        # validate query
        if (@input[1] != "FROM")
            puts "Invalid syntax"
            get_input()
        end
        if (!table)
            puts "No table selected"
            get_input()
        end
    
        # get where column & criteria
        where = cli_input.split("WHERE").last
        where = where.split("=")
        where[0].tr!(" ", "")
        where[1] = where[1].match(/'.*?'/).to_s
        where[1].slice!(0)
        where[1].chop!
    
        # execute query
        puts "@@csvr.delete.from(#{table}).where(#{where[0]},#{where[1]})"
    end
end

interface = CLI_Interface.new

interface.get_input


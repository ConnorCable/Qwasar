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
            if (@cli_input.include? "JOIN")
                puts "cli_join run"
                cli_join()
            end
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
        # SELECT name, weight FROM data.csv JOIN data_to_join ON name = player
        # SELECT name, weight FROM data.csv
        if @cli_input.include? "JOIN"
            column = @cli_input.split("FROM").first.tr("SELECT ", "").split(",")
            table = @cli_input.split("FROM").last.split("JOIN").first.tr!(" ", "")
        else
            column = @cli_input.split("FROM").first.tr("SELECT ", "").split(",")
            table = @cli_input.split("FROM").last.tr!(" ", "")
        end


    
        # validate query
        if (!@cli_input.include? "FROM" || !table || (column.include? " ") )
            raise "Invalid Syntax \n\tSYNTAX: SELECT column1, column2 FROM table"
            get_input()
        end
        # execute query
        #puts "@@csvr.select(#{column}).from(#{table}).run"
        @@csvr.select(column).from(table).run
        get_input()
    end
    
    def cli_insert()
        table = @input[2]# parse values
        values = @cli_input.split("VALUES").last # split @input string into array, get everything right of VALUES
        values.tr!("();", "").slice!(0)# clean up string

        # select everything in double quotes, reject indices with just quotes, empty strings, or just spaces
        arr = values.split(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/).reject{|elem| elem == ', ' || elem == " " || elem == "" || elem.empty?}
        # validate query
        if (@input[1] != "INTO" || !table || @input[3] != "VALUES" || values.size == 0)
            puts "Invalid Syntax:\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
            get_input()
        end
        
        @@csvr.insert(table) # initialize headers by using the .insert function, they can be accessed with @@csvr.headers
        newhash = {}
        # the following loop will take all the inputs and map them to a hash with the correct keys
        # The headers are extracted from @@csvr.headers
        # The output -> newhash = {:header1 => value1, :header2 => value2, ...}

        (0...arr.size).each do |i| # input: array , empty hash
            arr[i].gsub!('"',"") # removes the extra pair of quotes from a string
            if Integer(arr[i], exception:false).nil? # can the element NOT be cast as an integer?
                newhash[@@csvr.headers[i]] = arr[i] # if so, just add it to the hash as normal
                next
            end
            newhash[@@csvr.headers[i]] = arr[i].to_i # cast it as an integer, add it to a hash
        end

        # INSERT INTO data.csv VALUES ("Thanh N", 1996, 2022, F-C, 5-7, 143, "Oct 1, 1996", "Alameda College")
        @@csvr.values(newhash).run
        get_input()
    end

    # user for converting key values to it appropriate data type
    def match_symbol_to_data(arr)
        hash = {}
        arr.each_with_index do |element, index|
            if index.even?
                element.tr!(",= ","")
                if Integer(arr[index+1], exception: false).nil? 
                    hash[arr[index].to_sym] = arr[index+1].gsub('"',"")
                else
                    hash[arr[index].to_sym] = arr[index+1].gsub('"',"").to_i
                end
            end
        end
        return hash
    end

    def cli_update()
        table = @input[1]

        # validate query
        if (!table || @input[2] != "SET" || (!@cli_input.include? "WHERE") )
            puts "Invalid Syntax \n\tSYNTAX: FROM table SET column = value WHERE column2 = value2"
            get_input()
        end
    
        # get set values
        set_values = @cli_input.split("SET").last.split("WHERE").first # get everything between WHERE and SET
        
        # clean up set values string
        set_values.chop!.slice!(0)

        # split up set_values string but ignore comma inside double quote
        arr = set_values.split(/(".*?"|[^",\s]+)(?=\s*,|\s*$)/).reject{|elem| elem == ', ' || elem == " " || elem == "" || elem.empty?}

        # convert columns new content to hash
        hash = match_symbol_to_data(arr)

        # get where_column & where_criteria
        where = @cli_input.split("WHERE").last
        where = where.split("=")
        where[0].tr!(" ", "")
        where[1] = where[1].match(/'.*?'/).to_s
        where[1].slice!(0)
        where[1].chop!

        # execute query
        # UPDATE data.csv SET college = "University of California, Santa Cruz", name = "Connor" WHERE name = 'Thanh N';
        # Thanh N,1996,2022,F-C,5-7,143,"Oct 1, 1996",Alameda College
        @@csvr.update(table).set(hash).where(where[0],where[1]).run
        get_input
    end
    
    def cli_delete()
        table = @input[2]
        
        # validate query
        if (@input[1] != "FROM" || !table)
            puts "Invalid syntax"
            get_input()
        end
        
        # get where column & criteria
        where = @cli_input.split("WHERE").last
        where = where.split("=")
        where[0].tr!(" ", "")
        where[1] = where[1].match(/'.*?'/).to_s
        where[1].slice!(0)
        where[1].chop!
        

        # execute query
        # DELETE FROM data.csv WHERE name = 'Connor';
        @@csvr.delete.from(table).where(where[0],where[1]).run
        get_input()
    end

    def cli_join()
    # SELECT name, weight FROM data.csv JOIN data_to_join ON name = player

    join_query = @cli_input.split("JOIN").last
    table_to_join, data_to_join = join_query.split("ON")
    table_to_join.tr!(" ","")
    data_to_join = data_to_join.split("=")

    #puts "@@csvr.join(#{data_to_join[0]},#{table_to_join},#{data_to_join[1]})"
    @@csvr.join(data_to_join[0].tr!(" ", ""),table_to_join,data_to_join[1].tr!(" ", ""))


    end

    def cli_order()
        
    end
end

interface = CLI_Interface.new

interface.get_input


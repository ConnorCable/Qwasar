time = Time.new
puts "MySQLite version 0.1 #{time.strftime("%Y/%d/%m")}"
require_relative "req.rb"

csvr = MySqliteRequest.new

cli_input = ""
while (cli_input != "quit")
    # get user input
    cli_input = gets.chomp
    puts
    # parse user input
    input = cli_input.split

    case input[0]

        when "SELECT" # DONE 
        # SELECT * FROM students.db;
            column = input[1]
            table = input[3]

            # validate query
            if (!input[2] || !table)
                puts "No table to select from\n\tSYNTAX: SELECT `column` FROM `table`"
                next
            end

            # execute query
            puts csvr.select(column).from(table).run
        when "INSERT"
        # INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
            table = input[2]

            # parse values
            values = cli_input.split("VALUES")
            values = values[1]

            # clean up string
            values.tr!("();", "")
            values.tr!(" ", "")

            # validate query
            if (input[1] != "INTO")
                puts "Invalid syntax\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
                next
            end
            if (!table)
                puts "No table to selected"
                next
            end
            if (!input[3] || values.size == 0)
                puts "No values to be insert\n\tSYNTAX: INSERT INTO `table` VALUES (column1, column2, column3, ...)"
                next
            end
            
            # execute query
            puts "csvr.insert(#{table}).values(#{values})"
        when "UPDATE"
        # UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';
            table = input[1]
            # validate query
            if (!table)
                puts "No table selected"
                next
            end
            if (!input[2])
                puts "No column selected"
                next
            end
            if (!input.include? "WHERE")
                puts "Require criteria"
                next
        end

        # get set values
        set_values = cli_input.split("SET").last.split("WHERE").first
        set_values_arr = set_values.split(",")

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
        puts "csvr.update(#{table}).set(#{hash}).where(#{where[0]},#{where[1]})"
    when "DELETE"
    # DELETE FROM students WHERE name = 'John';
        table = input[2]

        # validate query
        if (input[1] != "FROM")
            puts "Invalid syntax"
            next
        end
        if (!table)
            puts "No table selected"
            next
        end

        # get where column & criteria
        where = cli_input.split("WHERE").last
        where = where.split("=")
        where[0].tr!(" ", "")
        where[1] = where[1].match(/'.*?'/).to_s
        where[1].slice!(0)
        where[1].chop!

        # execute query
        puts "csvr.delete.from(#{table}).where(#{where[0]},#{where[1]})"
    else
        puts "Invalid input."
    end
end
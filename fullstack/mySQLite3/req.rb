require 'csv'

class MySqliteRequest
    attr_accessor :headers


    def initialize()
        @headers = nil # contains the headers of the csv file
        @table_name = nil # contains the path to the table
        @table = nil # contains the parsed CSV file from the CSV gem
        @select = []
        @where_column = ''
        @where_criteria = ''
        @join_column_a = ''
        @db_b = ''
        @join_column_b = ''
        @select_results = []
        @values = []
        @query_type = nil
        @set_data = []
        @set_column = []
        @where_results = []
    end

    def query_checker(query)
        raise "Too many query types" unless @query_type == query
    end

    def table_builder(path) # intakes a csv file, outputs an array of hashes corresponding to the row of data. outputs the headers as well 
        if !path.end_with? ".csv" 
            path << ".csv"
        end
        table = []
        headers = nil
        CSV.foreach(path, headers: true ,header_converters: :symbol) do |hash| # iterate through rows of the CSV
            hash.each do |key, val| # iterate through the hash of the row
                if Integer(val, exception:false).nil? # if the value can be cast as an integer, do so
                    next
                end
                hash[key] = val.to_i # cast it to integer
            end
            headers ||= hash.headers
            table << hash.to_h # table is an array, append the hash to it as a hash
        end
        
        if @select[0] == "*"
            @select = headers.map{ |x| x.to_s} # if you are selecting all columns, then @select becomes the headers, which are all of the columns
        end
        return [table,headers]
    end

    def from(table_name) # loads a table to @table_name, will append .csv if necessary
        if !table_name.end_with? ".csv"
            table_name << ".csv"
        end
        @table_name = table_name
        @table, @headers = table_builder(@table_name)
        self
    end

    def select(*columns) # gets the columns of interest for the run_select column -> is run last after being narrowed by the run_where function
        if columns.class == Array
            columns = columns.flatten(1)
        end
        @select = columns
        @query_type ||= "select"
        query_checker("select")
        self
    end

    def run_where() # pushes the results of the "where" query to @where_results, which is a narrowed data set from our original table, used for the select command

        @table.each do |hash|
            if hash[@where_column.to_sym] == @where_criteria
                @where_results.push(hash)
            end
        end
    end

    def where(column, criteria) # gets the column and criteria for the run_where function
        @where_column = column
        @where_criteria = criteria
        self
    end

    def order(order, column_name) # order = string, column name = string
        table = @table.sort_by{|hsh| hsh[column_name.to_sym]}
        if order == "asc"
            @table.reverse!
        end
        self
    end

    def join(column_on_a, filename_db_b, columname_on_db_b) # gets the filename to be joined, as well as the columns to join
        @join_column_a = column_on_a
        @db_b = filename_db_b
        @join_column_b = columname_on_db_b
        self
    end

    def run_join() # joins the two csv tables together where entry_from_table_a[column_to_join_a] ==  entry_from_table_b[column_to_join_b]
                   # returns a new table called newtable with the merged rows
        csv1, headers1 = @table, @headers
        csv2, headers2 = table_builder(@db_b) # gets table 2 provided by the join function
        headers = (headers1 + headers2).uniq - [@join_column_b] # joins only unique headers together, removes column_to_join_b
        newtable = []
        i = 0

        csv1.each do |hashA|
            csv2.each do |hashB|
                if hashA[@join_column_a.to_sym] = hashB[@join_column_b.to_sym]
                    hashB.delete(@join_column_b.to_sym)
                    newtable[i] = hashA.merge(hashB)
                    i+=1
                end
            end
        end

        @table = newtable
        self
    end

    # INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
    # https://www.w3schools.com/mysql/mysql_insert.asp
    def insert(table_name)
        # insert function should:
        # build the table using table_builder, which initialized @table and @headers
        @table_name = table_name
        @table, @headers = table_builder(@table_name)
        @query_type ||= "insert"
        query_checker("insert")
        puts "Insert run!"
        self
    end

    def values(data)
        # validate the data
        raise "keys from data don't match headers" unless data.size == @headers.size and (data.keys - @headers).empty?
        @table.push(data)
        self
    end

    def update(table_name)
        @table_name = table_name
        @table, @headers = table_builder(table_name)
        @query_type ||= "update"
        query_checker("update")
        self
    end

    # update(table).set({name:Connor, email:ane@janedoe.com, blog: }).where({name:John}).run
    # UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';
    def set(data) # set needs to take in a hash, and then @set_data needs to be odd indexes , @set_columns are all the even index
        #raise "Set data already loaded" if @set_data
        @set_data = data
        self
    end
        
    def run()
        case @query_type
        when "select"
            if @db_b != ""
                puts "Run_join ran"
                run_join
            end
            if @where_column && @where_criteria.to_s
                run_where
            end
            run_select
        when "insert"
            update_table
        when "update"
            run_update
        when "delete"
            run_delete
        end
    end

    def run_select()
        if !@where_results.empty? # if the run_where command was run, select from only those narrowed results
            puts "where results loaded"
            @table = @where_results
        end

        @table.each_with_index do |hash| # iterate over hashes of the table
            newhash = {} # create a newhash to add to @select_results
            @select.each do |column| # passes in every header as an individual string
                newhash[column.to_sym] = hash[column.to_sym]
            end
            @select_results.push(newhash)
        end

        @select_results.each_with_index do |hash, index|
            output = ''
            #print hash
            hash.each do |key, value|
                output += value.to_s + "|"
            end
            output.chop!
            print output
            puts
        end

    end

    def update_table()
        temp_header_array = []
        @headers.each_with_index do |element, index| # push the headers to temp_header_array to append it to the csv
            temp_header_array.push(@headers[index].to_s)
        end
        CSV.open(@table_name, "w+") do |csv|
            csv << temp_header_array
                @table.each do |hash|
                csv << hash.values
            end
        end
    end

    # update(table).set({name:Connor, email:ane@janedoe.com, blog: }).where({name:John}).run
    # {name:Connor, email:ane@janedoe.com, blog: jane@janedoe.com}
    def run_update() #= instead of accessing things as an array 
        @table.each do |hash| # iterates over all the hashes in the array of hashes
            if hash[@where_column.to_sym] == @where_criteria # if the where criteria is met, then loop over all the key values in @set_data that you want to replace
                @set_data.each do |key, value| # loop over every kv that we need to replace
                    hash[key] = value
                end
            end
        end

       update_table()  
    end

    def run_delete()
        # table is an array of hashes table[i] == hash at i index
        @table.each do |element| # element is a hash
            if (element[@where_column.to_sym] == @where_criteria)
                # delete hash row
                @table.delete(element)
                puts "Record Deleted!"
            end
        end
        update_table()
    end

    def delete()
        @query_type = "delete"
        query_checker("delete")
        self
    end
end

# query - SELECT name FROM data.csv;
#csvr.select("*").from("data.csv").run
#csvr.delete(ASDasd).from(table).where("year_start", 2017)
# DELETE FROM students WHERE name = 'John';
#csvr.from("data.csv").select("name").where("weight",225).run
#csvr.update("mergeddb.csv").set({height: 999}).where("year_start",2017).run
#csvr.insert("mergeddb.csv").values({"name"=>"Alaa Abdelnaby", "year_start"=>1991, "year_end"=>1995, "position"=>"F-C", "height"=>"6-10", "weight"=>240, "birth_date"=>"June 24, 1968", "college"=>"Duke University"})
#csvr.select("name").from("data.csv").join("name","data_to_join.csv","player").run

=begin
1. Test Insert in CLI -> DONE
2. Test Update in CLI -> DONE
3. Test Delete in CLI -> DONE
4. Test Order -> MAY NOT NEED?
5. Test Order in CLI -> MAY NOT NEED
6. Test Join
7. Test Join in CLI
=end



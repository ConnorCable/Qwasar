require 'csv'

class MySqliteRequest
    attr_accessor :headers


    def initialize()
        @headers = nil
        @table_name = nil
        @table = nil
        @select = []
        @where_column = ''
        @where_criteria = ''
        @join_column_a = ''
        @db_b = ''
        @join_column_b = ''
        @select_results = []
        @values = []
        @query_type = nil
        @set_data = nil
        @where_results = []
    end

    def query_checker(query)
        raise "Too many query types" unless @query_type == query
    end

    def table_builder(path) # intakes a csv file, outputs an array of hashes corresponding to the row of data. outputs the headers as well
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
        @table = table
        @headers = headers
        if @select[0] == "*"
            @select = @headers.map{ |x| x.to_s} # if you are selecting all columns, then @select becomes the headers, which are all of the columns
        end
        self
    end

    def from(table_name) # loads a table to @table_name, will append .csv if necessary
        if !table_name.end_with? ".csv"
            table_name << ".csv"
        end
        table_builder(table_name)
        self
    end

    def select(*columns) # gets the columns of interest for the run_select column -> is run last after being narrowed by the run_where function
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
        csv1.each do |hashA| #iterate through table 1
            csv2.each do |hashB| # iterate through table 2
                if hashA[@join_column_a] == hashB[@join_column_b] # if the values match
                    merger = hashA.merge(hashB) # merge the hashes together
                    newtable[i] = merger unless hashA.merge(hashB).nil? # add the merged hash to the new table
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
        table_builder(@table_name)
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
        table_builder(table_name)
        @query_type ||= "update"
        query_checker("update")
        self
    end

    # update(table).set({name:Connor, email:ane@janedoe.com, blog: }).where({name:John}).run
    # UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';
    def set(data)
        raise "Set data already loaded" if @set_data
        flat = data.flatten
        @set_data = flat[1]
        @set_column = flat[0]
        self
    end
        
    def run()
        case @query_type
        when "select"
        if @where_column && @where_criteria.to_s
            run_where
        end
        run_select
        puts @select_results
        when "insert"
        run_insert
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
            newhash = Hash.new # create a newhash to add to @select_results
            @select.each do |column| # passes in every header as an individual string
                #@select_results.push(hash.slice(column.to_sym)) # @select_results = array of hashes
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

    def run_insert()
        temp_header_array = []
        @headers.each_with_index do |element, index| # push the headers to temp_header_array to append it to the csv
            temp_header_array.push(@headers[index].to_sym)
        end
        puts "run_insert run!"
        puts @table
        CSV.open(@table_name, "w+") do |csv|
        csv << temp_header_array
            @table.each do |hash|
                csv << hash.values
            end
        end
    end

    # update(table).set({name:Connor, email:ane@janedoe.com, blog: }).where({name:John}).run
    # {name:Connor, email:ane@janedoe.com, blog: jane@janedoe.com}
    def run_update()
        @table.each_with_index do |element, index| # element is a hash
            if (@table[index][@where_column.to_sym] == @where_criteria)
                @table[index][@set_column] = @set_data
            end
        end
    end

    def run_delete()
        # table is an array of hashes table[i] == hash at i index
        @table.each_with_index do |element, index| # element is a hash
            if (@table[index][@where_column.to_sym] == @where_criteria)
                # delete hash row
                @table.delete_at(index)
            end
        end
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


=begin
1. Test Insert in CLI
2. Test Update in CLI
3. Test Delete in CLI
4. Test Order
5. Test Order in CLI
6. Test Join
7. Test Join in CLI
=end



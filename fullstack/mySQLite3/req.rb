require 'csv'

class MySqliteRequest

    def initialize()
        @headers = nil
        @table_name = nil
        @table = []
        @select = []
        @where_column = ''
        @where_criteria = ''
        @join_column_a = ''
        @db_b = ''
        @join_column_b = ''
        @where_results = []
        @select_results = []
        @values = []
    end



    def from(table_name) # loads a table to @table_name, will append .csv if necessary
        raise "Table already loaded!!!!" if @table_name  
        if !(table_name.end_with? ".csv")
            table_name << ".csv"
        end
        @table_name = table_name
        self
    end

    def run_from() # outputs an array of hashes (@table) from data provided to the from function
        headers = nil
        if !@table_name
            raise "No table found!"
        end
        CSV.foreach(@table_name, headers:true, header_converters: :symbol) do
            |row|
                headers ||= row.headers
                @table << row.to_h
        end
        self
    end

    def table_builder(path) # intakes a csv file, outputs an array of hashes corresponding to the row of data. outputs the headers as well
        table = []
        headers = nil
        CSV.foreach(path, headers: true) do |hash| # iterate through rows of the CSV
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
        
        self
    end

    def select(*columns) # gets the columns of interest for the run_select column -> is run last after being narrowed by the run_where function
        @select = columns
        self
    end

    def run_select()
            @where_results.each do |row|
                @select.each do |param|
                    @select_results.push(row.slice(param.to_sym))
                end
            end
        puts @select_results
        self
    end

    def where(column, criteria) # gets the column and criteria for the run_where function
        @where_column = column
        @where_criteria = criteria
        self
    end

    def run_where() # pushes the results of the "where" query to @where_results, which is a narrowed data set from our original table
        @table.each do |row|
            if row[@where_column.to_sym] == @where_criteria
                @where_results.push(row)
            end
        end
        self
    end

    def order(order, column_name) # order = string, column name = string
        table = @table.sort_by{|hsh| hsh[column_name.to_sym]}
        if order == "asc"
            @table.reverse!
        end
        puts @table
        self
    end

    def join(column_on_a, filename_db_b, columname_on_db_b) # gets the filename to be joined, as well as the columns to join
        @join_column_a = column_on_a
        @db_b = filename_db_b
        @join_column_b = columname_on_db_b
        self
    end

    def run_join() # joins the two csv tables together where entry_from_table_a[column_to_join_a] ==  entry_from_table_b[column_to_join_b]
                   # returns a new table called newtable with the merged rows. headers are not appended yet, still figuring that out
        csv1, headers1 = table_builder(@table_name) # gets table 1 provided by the from function
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
        run_from()
        self
    end

    # INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
    # https://www.w3schools.com/mysql/mysql_insert.asp
    def insert(table_name)
        
        if @values.size == 0
            raise "No values specified!"
        end
        CSV.open(table_name, "w") do |csv|
            csv << @values
        end

    end
    def values(data)
        # validate data
        table_builder(table_name) ## initializes @headers and @table
        puts @headers.class
        if data.size != @headers.size
            raise "Not enough headers in your inputted data!"
        end
        keys = data.keys
        keys.each_with_index do |key, index|
            keys[index] = key.to_s
        end
        if (keys == @headers)
            @values = data
        else
            raise "Headers don't match"
        end
        #@headers.each do |header| # for each header in @headers
        #end
        # compare data keys with the keys from @headers
        # data = (a hash of data on format (key => value)
        self
    end
end

csvr = MySqliteRequest.new
#csvr.from("nba_player_data").run_from.select("name", "weight").where("weight", "215").run_where.run_select
#csvr.from("nba_player_data").join("name","nba_players.csv","Player").run_join.order("asc","weight")
csvr.values({:name=>"Alaa Abdelnaby", :year_start=>1991, :year_end=>1995, :position=>"F-C", :height=>"6-10", :weight=>240, :birth_date=>"June 24, 1968", :college=>"Duke University"})

testarr = [
    {name: "connor", age: "0", job: "Coder"},
    {name: "Josh", age: "23", job: "Dockworker"},
    {name: "Katy", age: "1000", job: "Student" }
]
# test order function
def order(arr,order, column_name)
    table = arr.sort_by{|hsh| hsh[column_name.to_sym]}
    if order == "desc"
        @table.reverse!
    end
    puts table
end

#order(testarr,"asc","age")
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
        CSV.foreach(path, headers: true, header_converters: :symbol) do |row|
            row.each do |key, val|
                if Integer(val, exception:false).nil?
                    next
                end
                row[key] = val.to_i
            end
            headers ||= row.headers
            table << row.to_h
        end
        @table = table
        @headers = headers
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

    def run_where() # pushes the results of the "where" query to @where results, which is a narrowed data set from our original table
        @table.each do |row|
            if row[@where_column.to_sym] == @where_criteria
                @where_results.push(row)
            end
        end
        self
    end

    def join(column_on_a, filename_db_b, columname_on_db_b) # gets the filename to be joined, as well as the columns to join
        @join_column_a = column_on_a
        @db_b = filename_db_b
        @join_column_b = columname_on_db_b
        self
    end

    # 
    #Order Implement an order method which will received two parameters, order (:asc or :desc) and column_name.
    #It will sort depending on the order base on the column_name.
    #It will be prototyped:
    
    # given: Array of hashes
    # [{:A=>A...},{:B=>B...}, {:C=>C...} ]
    # I need to take a specific key:value pair for each hash, and sort (ascending, descending) the array of hashes based on the value of the key:value pair

    def order(order, column_name)
        table = @table.sort_by{|hsh| hsh[column_name.to_sym]}
        if order == "desc"
            @table.reverse!
        end
        puts table
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


end

csvr = MySqliteRequest.new
#csvr.from("nba_player_data").run_from.select("name", "weight").where("weight", "215").run_where.run_select
#csvr.from("nba_player_data").join("name","nba_players.csv","Player").run_join.order("asc","weight")
csvr.table_builder("mergeddb.csv").order

testarr = [
    {name: "connor", age: "100", job: "Coder"},
    {name: "Josh", age: "2223", job: "Dockworker"},
    {name: "Katy", age: "3333", job: "Student" }
]

def order(arr,order, column_name)
    table = arr.sort_by{|hsh| hsh[column_name.to_sym]}
    if order == "desc"
        @table.reverse!
    end
    puts table
end

order(testarr,"asc","age")
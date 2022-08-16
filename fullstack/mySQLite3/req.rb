require 'csv'

class MySqliteRequest
    
    def initialize()
        @headers = ''
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



    def from(table_name)
        raise "Table already loaded!!!!" if @table_name  
        if !(table_name.end_with? ".csv")
            table_name << ".csv"
        end
        @table_name = table_name
    end

    def run_from()
        if !@table_name
            raise "No table found!"
        end
        CSV.foreach(@table_name, headers:true, header_converters: :symbol) do
            |row|
                headers ||= row.headers
                @table << row.to_h
        end
    end

    def select(*columns)
        @select = columns
    end

    def run_select()
            @where_results.each do |row|
                @select.each do |param|
                    set.push(row.slice(param.to_sym))
                end
            end
        puts @select_results
    end

    def where(column, criteria)
        @where_column = column
        @where_criteria = criteria
    end

    def run_where()
        @table.each do |row|
            if row[@where_column.to_sym] == @where_criteria
                @where_results.push(row)
            end
        end
    end

    def join(column_on_a, filename_db_b, columname_on_db_b)
        @join_column_a = column_on_a
        @db_b = filename_db_b
        @join_column_b = columname_on_db_b
    end

    def run_join()
        # @table_name, @db_b, @join_column_a, @join_column_b

        csv1 = CSV.read(@table_name, headers: true).by_col
        csv2 = CSV.read(@db_b, headers:true).by_col
        csv2.each do |col|
            if col[0] == @join_column_b
                csv2.delete(col)
            end
        end
        csv.open("joined.csv", "w") do |csv|
            
        end


    end


end

csvr = MySqliteRequest.new
csvr.from("nba_player_data")
csvr.run_from
csvr.select("name", "weight")
csvr.where("weight", "215")
csvr.run_where
csvr.run_select

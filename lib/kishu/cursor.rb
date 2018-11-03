

module Kishu
  class Cursor

    include Enumerable
    # Initializes a new Cursor

    def initialize options={}
      @collection = []
      # @before = options.fetch(:after_key,nil)
    end

    def each(start = 0)
      return to_enum(:each, start) unless block_given?
  
      Array(@collection[start..-1]).each do |element|
        yield(element)
      end
  
      unless last?
        start = [@collection.size, start].max
  
        fetch_next_page
  
        each(start, &Proc.new)
      end
    end

  private

    def client
      @client ||= Client.new()
    end

    # # @return [Integer]
    # def next_cursor
    #   @attrs[:next_cursor]
    # end
    # alias next next_cursor

    # # @return [Boolean]
    def last?
      start = [@collection.size, start].max
      fetch_next_page
      
      each(start, &Proc.new)
      # return false if next_cursor.is_a?(String)
      # return true if next_cursor.nil?
      # next_cursor.zero?
    end

    # # @return [Boolean]
    # def reached_limit?
    #   @limit && @limit <= attrs[@key].count
    # end

    # @return [Hash]
    def fetch_next_page
      response = @client.get({after_key: options[:after_key]})
      @collection += response
    end


    

    # @param attrs [Hash]
    # # @return [Hash]
    # def attrs=(attrs)
    #   @attrs = attrs
    #   @attrs.fetch(@key, []).each do |element|
    #     @collection << (@klass ? @klass.new(element) : element)
    #   end
    #   @attrs
    # end
  end
end
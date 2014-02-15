require 'kaminari'
require 'kaminari/models/array_extension'

module RedisModel
  module Helpers
    # Public: Pagination helper for elements contained in a sorted set defined
    # based on RedisModel.
    #
    # Example:
    #
    #   paginator = RedisModel::Helpers::SortedSetPaginator.new(sorted_set_object)
    #
    #   paginator.per(10).page(2)
    #   # => Returns objects in the second page.
    #
    # Elements in sorted set is ordered in descending score order, which is
    # consistent with that of RedisModel::Types::SortedSet handles the object.
    class SortedSetPaginator
      include Enumerable

      def initialize(sorted_set)
        @sorted_set = sorted_set
      end

      def load_default_options
        @per ||= 20
        @page ||= 1
      end

      def page(page_number)
        @page = page_number.to_i

        self
      end

      def per(number_per_page)
        @per = number_per_page.to_i

        self
      end

      def since_id(id)
        @since = id

        self
      end

      def max_id(id)
        @max = id

        self
      end

      def each(&block)
        result.each do |element|
          yield element
        end
      end

      def result
        load_default_options

        @result ||= (@since || @max) ? result_with_score : result_with_rank
      end

      def result_with_score
        raw_result = @sorted_set.get_range(@since || '-inf', @max || '+inf')

        Kaminari.paginate_array(raw_result).page(@page).per(@per)
      end

      def result_with_rank
        from = (@page - 1) * @per
        to = from + @per - 1

        @sorted_set.get_range_by_rank(from, to)
      end
    end
  end
end

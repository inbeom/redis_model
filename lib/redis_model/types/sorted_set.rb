module RedisModel
  module Types
    # Internal: Methods needed for Sorted Set type. Note that it assumes
    # elements are sorted in descending order of score as default because the
    # module is implemented for leaderboard feature. Future releases will
    # revert this decision and will use default order of Redis.
    module SortedSet
      include RedisModel::Types::Base

      # Public: Fetches elements in the sorted set as Array.
      #
      # Returns Array containing elements in the set.
      def to_a
        get_range('-inf', '+inf', include_boundaries: true)
      end

      # Public: Counts number of elements in (from, to) interval using ZCOUNT
      # command.
      #
      # from - Beginning point of the interval.
      # to   - Ending point of the interval.
      #
      # Returns Integer containing number of elements in the interval.
      def count_range(from, to)
        connection.zcount(key_label, from, to)
      end

      # Public: Asserts value is included in the set.
      #
      # Returns true if value is included in the set, false otherwise.
      def include?(value)
        !!connection.zrank(key_label, value)
      end

      # Public: Retrieves elements in [from, to] index interval. Elements are
      # arranged in descending order of score. ZREVRANGE command is used.
      #
      # from    - Beginning point of the index interval.
      # to      - Ending point of the index interval.
      # options - Additional options for retrieval.
      #           :withscores - If it is set to true, returned array
      #                         contains values and corresponding scores
      #                         of elements.
      #
      # Returns Integer containing number of elements in the interval.
      def get_range_by_rank(from, to, options = {})
        connection.zrevrange(key_label, from, to, options)
      end

      # Public: Retrieves elements in (from, to) index interval. Elements are
      # arranged in ascending order of score. ZRANGE command is used.
      #
      # from    - Beginning point of the index interval.
      # to      - Ending point of the index interval.
      # options - Additional options for retrieval.
      #           :withscores - If it is set to true, returned array
      #                         contains values and corresponding scores
      #                         of elements.
      #
      # Returns Integer containing number of elements in the interval.
      def get_range_by_reverse_rank(from, to, options = {})
        connection.zrange(key_label, from, to, options)
      end

      # Public: Retrieves index of element in the sorted set. Elements are
      # arranged in descending order of score. ZREVRANK command is used.
      #
      # from    - Beginning point of the index interval.
      # to      - Ending point of the index interval.
      # options - Additional options for retrieval.
      #           :withscores - If it is set to true, returned array
      #                         contains values and corresponding scores
      #                         of elements.
      #
      # Returns Integer containing number of elements in the interval.
      def get_rank(key)
        connection.zrevrank(key_label, key)
      end

      # Public: Retrieves score of element having specified value using ZSCORE
      # command.
      #
      # value - Value of the element in concern.
      #
      # Returns score of element.
      def score(value)
        connection.zscore(key_label, value)
      end

      # Public: Retrieves length of Redis sorted set using ZCARD command.
      #
      # Returns Integer containing cardinality of the sorted set.
      def count
        connection.zcard(key_label)
      end

      alias_method :length, :count

      # Public: Retrieves elements in the sorted set in (from, to) interval
      # using ZREVRANGEBYSCORE command.
      #
      # from    - Beginning point of the interval.
      # to      - Ending point of the interval.
      # options - Additional options for retrieval.
      #           :include_boundaries - If it is set to true, elements on
      #                                 beginning/ending points are included.
      #           :withscores         - If it is set to true, returned array
      #                                 contains values and corresponding scores
      #                                 of elements.
      #
      # Returns Array of element values or value/score pairs.
      def get_range(from, to, options = {})
        if options.delete(:include_boundaries)
          connection.zrevrangebyscore(key_label, to, from, options)
        else
          connection.zrevrangebyscore(key_label, "(#{to}", "(#{from}", options)
        end
      end

      # Public: Puts an element in sorted set using ZADD command.
      #
      # score - Score for the element.
      # value - Value for the element.
      #
      # Returns true.
      def put(score, value)
        connection.zadd(key_label, score, value)
      end

      # Public: Removes an element from the sorted set using ZREM command.
      #
      # value - Value to remove.
      #
      # Returns true.
      def remove(value)
        connection.zrem(key_label, value)
      end

      # Public: Removes elements of the sorted set in specified interval using
      # ZREMRANGEBYSCORE command.
      #
      # from - Beginning point of the interval (default: '-inf').
      # to   - Ending point of the interval (default: '+inf').
      #
      # Returns true.
      def remove_range(from = '-inf', to = '+inf')
        connection.zremrangebyscore(key_label, from, to)
      end

      # Public: Duplicates the sorted set with new key label using ZUNIONSTORE
      # command.
      #
      # Returns true if duplication was successful, false otherwise.
      def duplicate(new_key_label)
        connection.zunionstore(new_key_label, [key_label]) if exists?
      end

      # Public: Generates intersected sorted set with another sorted set or set
      # and perform operations on the new intersected set optionally.
      #
      # set     - Another set to perform intersection with the sorted set.
      # options - Additional options for the intersection.
      #           :seed - Seed for the new key label used to avoid naming
      #                   confliction.
      # block   - An optional block that performs RedisModel commands with the
      #           intersected sorted set. If the block is given, intersected
      #           sorted set is removed after commands are completed.
      #
      # Returns RedisModel::Intersected object resulted from intersection if
      #   block was not given. If block was given, result of block is returned.
      def intersect(set, options = {}, &block)
        result = intersected = RedisModel::Intersected.new([self, set], options[:seed])

        if block_given?
          intersected.generate
          result = yield(intersected)
          intersected.clear
        end

        result
      end

      # Public: Obtain rank-sampled keys from the sorted set.
      #
      # count - Number of keys to sample
      #
      # Returns Array of sampled keys.
      def sample(count = 1)
        (0...count).to_a.sample(count).map do |sampled_rank|
          connection.zrevrange(key_label, sampled_rank, sampled_rank)
        end.compact.map(&:first)
      end
    end
  end
end

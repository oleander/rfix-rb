module Rfix
  module Branch
    class Name < Base
      attr_reader :name

      def initialize(name)
        super()
        @name = name
      end

      def resolve(with:)
        unless branch = with.branches[name]
          raise Branch::UnknownBranchError, "Could not find branch {{error:#{name}}}"
        end

        with.lookup(with.merge_base(branch.target_id, with.head.target_id))
      rescue Rugged::ReferenceError
        raise Branch::UnknownBranchError, "Could not find branch {{error:#{name}}}"
      end

      alias to_s name
    end
  end
end

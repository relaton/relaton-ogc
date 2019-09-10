module RelatonOgc
  class HashConverter < RelatonIsoBib::HashConverter
    class << self
      private

      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        eg = ret[:editorialgroup]
        return unless eg

        ret[:editorialgroup] = EditorialGroup.new(
          committee: eg[:committee],
          subcommittee: eg[:subcommittee],
          workgroup: eg[:workgroup],
          secretariat: eg[:secretariat],
        )
      end
    end
  end
end

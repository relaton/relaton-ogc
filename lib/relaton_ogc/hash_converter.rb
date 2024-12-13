module RelatonOgc
  module HashConverter
    include RelatonBib::HashConverter
    extend self

    private

    # @param ret [Hash]
    def editorialgroup_hash_to_bib(ret)
      eg = ret.dig(:ext, :editorialgroup) || ret[:editorialgroup] #@TODO: remove ret[:editorialgroup] after all gem will be updated
      return unless eg

      ret[:editorialgroup] = EditorialGroup.new(
        committee: eg[:committee],
        subcommittee: eg[:subcommittee],
        workgroup: eg[:workgroup],
        secretariat: eg[:secretariat],
      )
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end

module RelatonOgc
  # OGC project group.
  class EditorialGroup
    include RelatonBib

    COMMITTEES = %w[technical planning strategic-member-advisory].freeze

    # @return [String]
    attr_reader :committee

    # @return [RelatonIsoBib::IsoSubgroup]
    attr_reader :subcommittee

    # @return [RelatonIsoBib::IsoSubgroup]
    attr_reader :workgroup

    # @param committee [String]
    #
    # @param subcommittee [Hash, RelatonIsoBib::IsoSubgroup]
    # @option subcommittee [String] :name
    # @option subcommittee [String] :type
    # @option subcommittee [Integer] :number
    #
    # @param workgroup [Hash, RelatonIsoBib::IsoSubgroup]
    # @option workgroup [String] :name
    # @option workgroup [String] :type
    # @option workgroup [Integer] :number
    def initialize(committee:, **args)
      unless COMMITTEES.include? committee
        raise ArgumentError, "committee is invalid: #{committee}"
      end

      @committee    = committee
      @subcommittee = subgroup args[:subcommittee]
      @workgroup    = subgroup args[:workgroup]
    end

    # @return [true]
    def presence?
      true
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.editorialgroup do
        builder.committee committee
        builder.subcommittee { subcommittee&.to_xml builder } if subcommittee
        builder.workgroup { workgroup&.to_xml builder } if workgroup
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "committee" => committee }
      hash["subcommittee"] = subcommittee.to_hash if subcommittee
      hash["workgroup"] = workgroup.to_hash if workgroup
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix)
      pref = prefix.empty? ? prefix : prefix + "."
      pref += "editorialgroup"
      out = "#{pref}.committee:: #{committee}\n"
      out += subcommittee.to_asciibib "#{pref}.subcommittee" if subcommittee
      out += workgroup.to_asciibib "#{pref}.workgroup" if workgroup
      out
    end

    private

    # @param group [Hash, RelatonIsoBib::IsoSubgroup]
    # @return {RelatonIsoBib::IsoSubgroup}
    def subgroup(group)
      if group.is_a?(Hash)
        RelatonBib::WorkGroup.new(**group)
      else group
      end
    end
  end
end

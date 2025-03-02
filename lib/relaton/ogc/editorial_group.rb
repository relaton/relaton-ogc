module Relaton
  module Ogc
    class EditorialGroup < Lutaml::Model::Serializable
      attribute :committee, :string, values: %w[technical planning strategic-member-advisory]
      attribute :subcommittee, Bib::WorkGroup
      attribute :workgroup, Bib::WorkGroup

      xml do
        map_element "committee", to: :committee
        map_element "subcommittee", to: :subcommittee
        map_element "workgroup", to: :workgroup
      end
    end
  end
end

module Relaton
  module Ogc
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end

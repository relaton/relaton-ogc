module Relaton
  module Ogc
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end

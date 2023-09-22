module RelatonOgc
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonOgc.configuration.logger
    end
  end
end

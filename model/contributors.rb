require_relative '../setup'

class Contributors
  def self.for(cid)
    JSON.parse(File.read("data/contributors/#{cid}.json"))
  end
end

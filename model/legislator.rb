require 'json'

class States
  include Enumerable
  def each &block
    states ||= JSON.parse(File.read("data/states.json"))
    states.each do |state|
      block.call state
    end
  end
end


class Legislators
  include Enumerable
  def each &block
    legislators.each do |legislator|
      block.call legislator
    end
  end

  def legislators
    States.new.collect do |state|
      legislators_for(state["abbreviation"])
    end.flatten
  end

  def legislators_for(state_abbreviation)
    JSON.parse(File.read("data/legislators/#{state_abbreviation}.json"))
  end

  def self.find_by_twitter_username(username)
    new.find { |l| l[:twitter_id] == username }
  end

  def self.with_contributor_data(legislators)
    legislators.select { |l| File.exists?("data/contributors/#{l["cid"]}.json") }
  end

  def self.legislators_on_twitter
    new.reject { |l| l["twitter_id"].empty? }
  end
end

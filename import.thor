require_relative './setup'

class Import < Thor
  desc "legislators", "save legislators to json"
  def legislators
    states.each do |state|
      legislators = member.get_legislators(id: state["abbreviation"])["response"]["legislator"]

      file = File.new("data/legislators/#{state["abbreviation"]}.json",  "w+")
      JSON.dump legislators, file
      sleep 0.5
    end
  end

  desc "contributors", "save legislators contributors to json"
  def contributors
    states.map do |state|
      legislators = JSON.parse(File.read("data/legislators/#{state["abbreviation"]}.json"))
      legislators.each do |legislator|
        begin
          cid = (legislator.is_a? String) ? legislator : legislator["cid"]
        rescue TypeError => e
          next
        end
        next if File.exists?("data/contributors/#{cid}.json")

        response = candidate.contributors(cid: cid)

        begin
          contributors = response["response"]["contributors"]["contributor"]
        rescue MultiXml::ParseError
          next
        end

        File.open("data/contributors/#{legislator["cid"]}.json",  "w+") do |f|
          JSON.dump contributors, f
        end
        sleep 0.5
      end
    end
  end

  private

  def member
    @member ||= OpenSecrets::Member.new
  end

  def candidate
    @candidate ||= OpenSecrets::Candidate.new
  end

  def states
    @states ||= JSON.parse(File.read("data/states.json"))
  end

end

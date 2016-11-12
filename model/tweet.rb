require_relative '../setup'
require_relative './legislator'
require_relative './contributors'
require 'twitter'
require 'virtus'

class RandomTweetWithSponsorInfo
  include Virtus.model

  attribute :tweet, Twitter::Tweet
  attribute :congress_member, String
  attribute :contributor, Hash

  def self.get
    random_legislator = with_contributor_data(
      Legislators.legislators_on_twitter
    ).sample
    contributors = Contributors.for(random_legislator["cid"])
    random_contributor = contributors.sample
    timeline = client.user_timeline random_legislator["twitter_id"]
    # timeline.reject! { |t| t.text.length > (140 - rando_sponsor_msg.length) }

    if timeline.any?
      random_tweet = timeline.sample
      new(
        tweet: random_tweet,
        congress_member: random_legislator,
        contributor: random_contributor
      )
    end
  rescue Twitter::Error::NotFound
    puts "toot?"
  end

  def self.with_contributor_data(legislators)
    legislators.select { |l| File.exists?("data/contributors/#{l["cid"]}.json") }
  end

  def self.client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end
end

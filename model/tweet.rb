require_relative '../setup'
require_relative './legislator'
require_relative './contributors'
require 'twitter'
require 'virtus'

class Tweet
  include Virtus.model

  attribute :original_tweet_id, Integer
  attribute :text, String

  def self.generate_tweet
    rando_leg = with_contributor_data(Legislators.legislators_on_twitter).sample
    rando_contributor = Contributors.for(rando_leg["cid"]).sample
    rando_sponsor_msg = "Sponsored by #{rando_contributor['org_name']} - "

    timeline = client.user_timeline rando_leg["twitter_id"]
    timeline.reject! { |t| t.text.length > (140 - rando_sponsor_msg.length) }

    if timeline.any?
      original_tweet = timeline.sample
      new(
        original_tweet_id: original_tweet.id,
        text: rando_sponsor_msg + original_tweet.text
      )
    else
      generate_tweet
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

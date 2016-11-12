require_relative 'setup'
require_relative 'model/tweet'
require 'twitter'

class GenerateAndPostTweet
  def self.run
    selected_tweet = RandomTweetWithSponsorInfo.get

    sponsored_message = "^^ This message brought to you by #{selected_tweet.contributor["org_name"]}."

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end

    client.update(
      sponsored_message,
      in_reply_to_status_id: selected_tweet.tweet.id
    )

    client.retweet(selected_tweet.tweet)
  end
end

GenerateAndPostTweet.run

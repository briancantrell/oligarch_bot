require_relative 'setup'
require_relative 'model/tweet'
require 'twitter'
require 'slack-ruby-bot'

class PickerBot < SlackRubyBot::Bot
  command 'compose tweets' do |client, data, match|
    @current_batch = 10.times.map do
      Tweet.generate_tweet
    end

    menu = @current_batch.each_with_index.map do |tweet, i|
      "#{i} - #{tweet.text} - #{tweet.congress_member}"
    end

    client.say(text: menu.join("\n"), channel: data.channel)
  end

  command 'publish tweet' do |client, data, match|
    selected_tweet = @current_batch[match["expression"].to_i]
    Twitter.update(
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
      selected_tweet.text,
      in_reply_to_status_id: selected_tweet.original_tweet_id
    )
  end
end

PickerBot.run

require_relative 'setup'
require_relative 'model/tweet'
require 'twitter'
require 'slack-ruby-bot'

class PickerBot < SlackRubyBot::Bot
  command 'list tweets' do |client, data, match|
    @current_batch = 10.times.map do
      RandomTweetWithSponsorInfo.get
    end

    menu = @current_batch.each_with_index.map do |random_tweet, i|
      "#{i} - #{random_tweet.tweet.text} - #{random_tweet.congress_member} \n" +
        random_tweet.contributors.map { |contributor| contributor["org_name"] }.join(", ") + "\n\n"
    end

    client.say(text: menu.join("\n"), channel: data.channel)
  end

  command 'select tweet' do |client, data, match|
    @selected_tweet = @current_batch[match["expression"].to_i]

    menu = @selected_tweet.contributors.each_with_index.map do |contributor, i|
      "*#{i} - #{contributor["org_name"]}*"
    end

    client.say(text: menu.join("\n"), channel: data.channel)
  end

  command 'select contributor' do |client, data, match|
    @selected_contributor = @selected_tweet.contributors[match["expression"].to_i]

    @sponsored_message = "^^ This message brought to you by #{@selected_contributor["org_name"]}."

    preview  = <<-EOF
      #{@selected_tweet.tweet.text}
      #{@selected_tweet.congress_member}

      #{@sponsored_message}

      Look good?
    EOF

    client.say(text: preview, channel: data.channel)
  end

  command 'tweet' do |client, data, match|
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end

    client.update(
      @sponsored_message,
      in_reply_to_status_id: @selected_tweet.tweet.id
    )
    client.retweet(@selected_tweet.tweet)
  end
end

PickerBot.run

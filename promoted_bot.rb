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
      "#{i} - #{tweet.text} - "
    end

    client.say(text: menu.join("\n"), channel: data.channel)
  end

  command 'publish tweet' do |client, data, match|
    selected_tweet = @current_batch[match["expression"].to_i]
    Twitter.update(
      selected_tweet.text,
      in_reply_to_status_id: selected_tweet.original_tweet_id
    )
  end
end

PickerBot.run

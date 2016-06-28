require_relative './setup'
require_relative './model/tweet'

class TweetTool < Thor
  desc "makem", "make the toots"
  def toot(count = 10)
    count.times do
      Tweet.generate_tweet
    end
  end
end

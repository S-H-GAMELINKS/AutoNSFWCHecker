# Using Google Cloud Vision API for Ruby
require "google/cloud/vision"
require "dotenv"
require "json"
require 'mastodon'

Dotenv.load

file = File.open(ENV["VISION_KEYFILE"])
env = JSON.parse(file.read).to_h

vision = Google::Cloud::Vision.new project: env["project_id"].to_s

stream = Mastodon::Streaming::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])
client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"], bearer_token: ENV["MASTODON_ACCESS_TOKEN"])

# Streaming for Local TimeLine
stream.firehose() do |toot|
    if toot.uri.to_s =~ /#{ENV['MASTODON_URL'].to_s}/ 
        toot.media_attachments.each do |media|
            response = vision.image(media.url).safe_search

            if response.adult? 
                client.create_status("@#{toot.account.acct}@#{ENV["MASTODON_URL"].gsub!(/https:\/\//, '')} えっちい画像なのでNSFWをつけてください……")
            elsif response.violence?
                client.create_status("@#{toot.account.acct}@#{ENV["MASTODON_URL"].gsub!(/https:\/\//, '')} 暴力的な画像なのでNSFWをつけてください……")
            elsif response.medical?
                client.create_status("@#{toot.account.acct}@#{ENV["MASTODON_URL"].gsub!(/https:\/\//, '')} 医療系な画像なのでNSFWをつけてください……")
            end
        end
    end
end
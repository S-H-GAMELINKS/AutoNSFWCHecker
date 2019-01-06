# Using Google Cloud Vision API for Ruby
require "google/cloud/vision"
require "dotenv"
require "json"

Dotenv.load

file = File.open(ENV["VISION_KEYFILE"])
env = JSON.parse(file.read).to_h

vision = Google::Cloud::Vision.new project: env["project_id"].to_s

filename = "./sample.jpg"

response = vision.image(filename).safe_search
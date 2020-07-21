require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

 enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key    = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
end

get '/' do
  erb :index
end

get '/make' do
  @contents = Image.all
  @puzzles = Puzzle.all
  erb :make
end

get '/solve' do
  erb :solve
end

post '/new' do
  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end

  Image.create({
    img: img_url,
    puzzle_id: params[:puzzle_id]
  })

  redirect '/make'
end

post '/new_puzzle' do
  Puzzle.create({
    name: params[:name]
  })
  redirect '/make'
end


post '/delete_image/:id' do
  Image.find(params[:id]).destroy

  redirect '/make'
end

post '/delete_puzzle/:id' do
  Puzzle.find(params[:id]).destroy

  redirect '/make'
end

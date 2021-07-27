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
  @puzzles = Puzzle.all
  puzzle = [@puzzles]
  puzzle.shuffle
  rng = Random.new
  rng2 = rng.dup
  erb :solve
end

post '/new/:id' do
  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end

  # binding.pry

  Image.create({
    img: img_url,
    puzzle_id: params[:id],
    answer_id: params[:id]
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

get '/user' do
  erb :index_user
end

get '/signin' do
  erb :sign_in
end

get '/signup' do
  erb :sign_up
end

post '/signin' do
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

post '/signup' do
  @user = User.create(mail:params[:mail], password:params[:password],
  password_confirmation:params[:password_confirmation])
  if @user.persisted?
    session[:user] = @user.id
  end
  redirect '/'
end

get '/signouot' do
  session[:user] = nill
  redirect '/'
end

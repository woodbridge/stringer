require 'sinatra'
require 'data_mapper'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"

class Post
  include DataMapper::Resource

  before :save do
    self.slug = self.title.downcase.gsub(' ', '-')
  end

  property :id,          Serial
  property :title,       String
  property :slug,        String
  property :body,        Text
  property :created_at,  DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

def authenticate!
  use Rack::Auth::Basic do |u, p| 
    u == 'admin' && p == 'password'
  end
end

get '/' do
  @posts = Post.all
  erb :index
end

get '/admin' do
  erb :admin
end

get '/:slug' do
  @post = Post.first slug: params[:slug]
  if @post
    erb :show
  else
    pass
  end
end

not_found do
  redirect '/'
end

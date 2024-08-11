# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'rack/protection'
require 'rack/utils'

use Rack::Protection

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

FILE_PATH = 'memos.json' # publicフォルダから移動

def load_memos
  if File.exist?(FILE_PATH) && !File.zero?(FILE_PATH)
    JSON.parse(File.read(FILE_PATH))
  else
    {}
  end
rescue JSON::ParserError
  {}
end

def save_memos(memos)
  File.open(FILE_PATH, 'w') do |file|
    file.write(JSON.generate(memos))
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = load_memos
  id = SecureRandom.uuid
  memos[id] = { 'title' => h(params[:title]), 'content' => h(params[:content]) }
  save_memos(memos)
  redirect '/memos'
end

get '/memos/:id' do
  @memo = load_memos[params[:id]]
  halt 404, erb(:not_found) unless @memo
  erb :show
end

get '/memos/:id/edit' do
  @memo = load_memos[params[:id]]
  halt 404, erb(:not_found) unless @memo
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  halt 404, erb(:not_found) unless memos[params[:id]]
  memos[params[:id]] = { 'title' => h(params[:title]), 'content' => h(params[:content]) }
  save_memos(memos)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = load_memos
  halt 404, erb(:not_found) unless memos.delete(params[:id])
  save_memos(memos)
  redirect '/memos'
end

not_found do
  erb :not_found
end

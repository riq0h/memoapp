# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi'

FILE_PATH = 'memos.json'

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

def load_memos
  if !File.zero?(FILE_PATH)
    JSON.parse(File.read(FILE_PATH))
  else
    {}
  end
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
  memos[id] = { 'title' => params[:title], 'content' => params[:content] }
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
  memos[params[:id]] = { 'title' => params[:title], 'content' => params[:content] }
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

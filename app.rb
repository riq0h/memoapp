# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'securerandom'
require 'cgi'

configure do
  set :conn, PG.connect(dbname: 'memo_app')
end

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end

  def db
    settings.conn
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = db.exec('SELECT * FROM memos').to_a
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  uuid = SecureRandom.uuid
  db.exec_params(
    'INSERT INTO memos (id, title, content) VALUES ($1, $2, $3)',
    [uuid, params[:title], params[:content]]
  )
  redirect '/memos'
end

get '/memos/:id' do
  @memo = db.exec_params('SELECT * FROM memos WHERE id = $1', [params[:id]]).first
  halt 404, erb(:not_found) unless @memo
  erb :show
end

get '/memos/:id/edit' do
  @memo = db.exec_params('SELECT * FROM memos WHERE id = $1', [params[:id]]).first
  halt 404, erb(:not_found) unless @memo
  erb :edit
end

patch '/memos/:id' do
  db.exec_params(
    'UPDATE memos SET title = $1, content = $2 WHERE id = $3',
    [params[:title], params[:content], params[:id]]
  )
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  db.exec_params('DELETE FROM memos WHERE id = $1', [params[:id]])
  redirect '/memos'
end

not_found do
  erb :not_found
end

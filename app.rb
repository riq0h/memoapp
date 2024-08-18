# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
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

  def find_memo(id)
    db.exec_params('SELECT * FROM memos WHERE id = $1', [id]).first
  end

  def create_memo(title, content)
    db.exec_params(
      'INSERT INTO memos (title, content) VALUES ($1, $2) RETURNING id',
      [title, content]
    ).first['id']
  end

  def update_memo(id, title, content)
    db.exec_params(
      'UPDATE memos SET title = $1, content = $2 WHERE id = $3',
      [title, content, id]
    )
  end

  def delete_memo(id)
    db.exec_params('DELETE FROM memos WHERE id = $1', [id])
  end

  def all_memos
    db.exec('SELECT * FROM memos ORDER BY created_at DESC').to_a
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = all_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  id = create_memo(params[:title], params[:content])
  redirect "/memos/#{id}"
end

get '/memos/:id' do
  @memo = find_memo(params[:id])
  halt 404, erb(:not_found) unless @memo
  erb :show
end

get '/memos/:id/edit' do
  @memo = find_memo(params[:id])
  halt 404, erb(:not_found) unless @memo
  erb :edit
end

patch '/memos/:id' do
  update_memo(params[:id], params[:title], params[:content])
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  delete_memo(params[:id])
  redirect '/memos'
end

not_found do
  erb :not_found
end

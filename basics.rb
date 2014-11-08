
# Singing with Sinatra Part One


require 'sinatra'
require 'datamapper'


# Root page
get '/' do
  "Hello Sinatra!"
end


# About page
get '/about' do
  'A little about me.'
end


# Param page 
get '/hello/:name' do
  "Hello there, #{params[:name]}."
end


# Form Page
get '/form' do
  erb :form
end

post '/form' do
  "You said '#{params[:message]}'."
end


# Encrypt page
get '/encrypt' do
  erb :encrypt
end

post '/encrypt' do
  params[:encrypt].reverse
end

# Decrypt page
get '/decrypt/:encrypt' do
  params[:encrypt].reverse
end


# 404 Page
not_found do
  halt 404, 'Page not found!'
end

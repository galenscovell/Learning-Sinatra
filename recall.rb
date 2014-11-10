
require 'sinatra'
require 'data_mapper'

# Flash message dependencies
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions
use Rack::Flash, :sweep => true


# Setup new database with SQLite3
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

# Creates h() method via Rack to escape submitted content
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end


# Homepage
get '/' do
  @notes = Note.all :order => :id.desc # All Note objects by id to ERB
  @title = 'All Notes' # Web page title for ERB
  if @notes.empty?
    flash[:error] = 'No notes found. Add your first below.'
  end
  erb :home
end


# Create new Note object on homepage when post request is made
post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  if n.save
    redirect '/', :notice => 'Note created!'
  else
    redirect '/', :error => 'Failed to create note.'
  end
end


# Edit Note
get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  if @note
    erb :edit
  else
    redirect '/', :error => 'Unable to find note.'
  end
end

put '/:id' do
  n = Note.get params[:id]
  unless n
    redirect '/', :error => 'Unable to find note.'
  end
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0
  n.updated_at = Time.now
  if n.save
    redirect '/', :notice => 'Note updated.'
  else
    redirect '/', :error => 'Error updating note.'
  end
end


# Delete Note
get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm deletion of note ##{params[:id]}"
  if @note
    erb :delete
  else
    redirect '/', :error => 'Unable to find note.'
  end
end

delete '/:id' do
  n = Note.get params[:id]
  if n.destroy
    redirect '/', :notice => 'Note deleted.'
  else
    redirect '/', :error => 'Unable to delete note.'
  end
end


# Complete Note
get '/:id/complete' do
  n = Note.get params[:id]
  unless n
    redirect '/', :error => 'Unable to find note.'
  end
  n.complete = n.complete ? 0 : 1
  n.updated_at = Time.now
  if n.save
    redirect '/', :notice => 'Note marked complete.'
  else
    redirect '/', :error => 'Error marking note as complete.'
  end
end


# Error page
not_found do
  halt 404, "Page not found."
end


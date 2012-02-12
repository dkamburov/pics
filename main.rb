 require 'sinatra'
require 'data_mapper'
require 'dm-paperclip'

APP_ROOT = File.expand_path(File.dirname(__FILE__))

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Image
include DataMapper::Resource
include Paperclip::Resource

  property :id,     Serial

  has_attached_file :file,
                    :url => "/files/:id.:extension",
                    :path => "#{APP_ROOT}/public/files/:id.:extension"
					
end

DataMapper.finalize
DataMapper.auto_upgrade!

def make_paperclip_mash(file_hash)
  mash = Mash.new
  mash['tempfile'] = file_hash[:tempfile]
  mash['filename'] = file_hash[:filename]
  mash['content_type'] = file_hash[:type]
  mash['size'] = file_hash[:tempfile].size
  mash
end

get '/' do
  haml :upload
end

get '/print' do
  Image.first
  haml :pr
end

post '/upload' do
  halt 409, "File seems to be emtpy" unless params[:file][:tempfile].size > 0
  @resource = Image.new(:file => make_paperclip_mash(params[:file]))
  @resource.save
  "Complete!"
end
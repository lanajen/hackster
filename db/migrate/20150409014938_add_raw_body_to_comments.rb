class AddRawBodyToComments < ActiveRecord::Migration
  def change
    add_column :comments, :raw_body, :text
  end
end

# require 'rinku'
# require 'nokogiri'

# Comment.order(:id).each do |comment|
#   raw_body = comment.body.gsub(/<br\s*\/?>/, "\n")
#   raw_body = Nokogiri::HTML::DocumentFragment.parse(raw_body).text
#   body = Rinku.auto_link(comment.body, :all, 'target="_blank"')
#   comment.update_column :body, body
#   comment.update_column :raw_body, raw_body
# end

class RemoveContentFilePrefixFromIpcontentsTable < ActiveRecord::Migration
  def self.up
    remove_column :ipcontents, :content_file_prefix
  end

  def self.down
    add_column :ipcontents, :content_file_prefix, :integer
  end
end

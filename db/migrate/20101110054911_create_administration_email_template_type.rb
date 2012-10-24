class CreateAdministrationEmailTemplateType < ActiveRecord::Migration
  def self.up
     create_table :email_template_types do |t|
      t.column :type,                     :string, :limit => 200
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    add_index :email_template_types, :type, :unique => true
  end

  def self.down
    drop_table :email_template_types
  end
end

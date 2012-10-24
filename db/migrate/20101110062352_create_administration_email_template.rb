class CreateAdministrationEmailTemplate < ActiveRecord::Migration
 def self.up

   create_table :email_templates do |t|
      t.column :name,                      :string, :limit => 100
      t.column :subject,                   :string, :limit => 250
      t.column :content,                   :text
      t.references :email_template_types
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    add_index :email_templates, :name, :unique => true
  end

  def self.down
    drop_table "email_templates"
  end
end

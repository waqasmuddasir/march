class ChangeColumnNameTemplateType < ActiveRecord::Migration
  def self.up
        rename_column :email_template_types, :type, :template_type
  end

  def self.down
        rename_column :email_template_types, :template_type, :type
  end
end

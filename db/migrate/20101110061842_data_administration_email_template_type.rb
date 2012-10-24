class DataAdministrationEmailTemplateType < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO email_template_types (id, type, created_at, updated_at) VALUES (1, 'Registration', '2010-11-05 11:59:49', '2010-11-05 11:59:52')"
    execute "INSERT INTO email_template_types (id, type, created_at, updated_at) VALUES (2, 'Sign Up Offer', '2010-11-05 11:59:49', '2010-11-05 11:59:52')"
    execute "INSERT INTO email_template_types (id, type, created_at, updated_at) VALUES (3, 'Package Offer', '2010-11-05 11:59:49', '2010-11-05 11:59:52')"
  end
    

  def self.down
    execute "DELETE FROM email_template_types WHERE id=1"
    execute "DELETE FROM email_template_types WHERE id=2"
    execute "DELETE FROM email_template_types WHERE id=3"
  end
end

class AdminUserData < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO admins (id, login, password, created_at, updated_at, is_super) VALUES (1, 'admin', '21232f297a57a5a743894a0e4a801fc3', '2010-11-05 11:59:49', '2010-11-05 11:59:52', 1)"
  end

  def self.down
    execute "DELETE FROM admins WHERE id=1"
  end
end

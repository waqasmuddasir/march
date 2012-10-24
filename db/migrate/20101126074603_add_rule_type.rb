class AddRuleType < ActiveRecord::Migration
  def self.up
    add_column :package_rules, :rule_type, :string
  end

  def self.down
    remove_column :package_rules, :rule_type
  end
end

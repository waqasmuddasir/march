class Administration::PackageAllowedTime < ActiveRecord::Base
  belongs_to :package_rule
 
end

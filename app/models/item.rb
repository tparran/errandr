class Item < ActiveRecord::Base
belongs_to :user
validates :name, :presence => true
validates :name, uniqueness: { case_sensitive: false, :scope => :user_id  }
end

class Provider < ActiveRecord::Base
  belongs_to :category
  has_many :archives

end

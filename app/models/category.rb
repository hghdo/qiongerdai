class Category < ActiveRecord::Base

  def archives
    Archive.where(["cat=?",self.alias]).order("pub_date desc").limit(10).all
  end

  def to_param
    self.alias
  end
end

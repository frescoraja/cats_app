class Cat < ActiveRecord::Base
  validates :name, presence: true

  has_many :toys
end

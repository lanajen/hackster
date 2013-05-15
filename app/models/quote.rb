class Quote < ActiveRecord::Base
  has_many :documents, as: :attachable

  attr_accessible :quantity, :materials, :manufacturer_preference,
    :email, :name, :comments, :manufacturer_comments, :documents_attributes
  accepts_nested_attributes_for :documents

  store :properties, accessors: [:quantity, :materials, :manufacturer_preference,
    :email, :name, :comments, :manufacturer_comments
  ]
end

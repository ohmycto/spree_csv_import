Product.class_eval do
  validates :code, :uniqueness => true, :length => { :maximum => 20 }
end
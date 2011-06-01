Product.class_eval do
  validates_length_of :code, :maximum => 20
end
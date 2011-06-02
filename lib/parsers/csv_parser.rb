class Parsers::CsvParser
  attr_accessor :title_row, :current_taxon, :current_root_taxon, :initial_taxon, :taxons, :products

  state_machine :state, :initial => :title do
    state :title do
      def parse(line)
        @title_row = line
        self.to_root_state
      end
    end

    state :root do
      def parse(line)
        return if line[0].blank?
        parse_taxon(line)
        self.to_taxon_state
      end
    end

    state :taxon do
      def parse(line)
        if line[0].blank?
          @current_taxon = @initial_taxon
          self.to_root_state
        elsif line[0] && !line[1]
          parse_taxon(line)
        else
          parse_product(line)
          self.to_product_state
        end
      end
    end

    state :product do
       def parse(line)
        if line[0].blank?
          @current_taxon = @initial_taxon
          self.to_root_state
        elsif line[0] && !line[1]
          parse_taxon(line)
          self.to_taxon_state
        else
          parse_product(line)
        end
      end
    end

    event :to_root_state do
      transition :title => :root, :taxon => :root, :product => :root
    end

    event :to_taxon_state do
      transition :product => :taxon, :root => :taxon
    end

    event :to_product_state do
      transition :product => :taxon, :root => :taxon
    end
  end

  def initialize(options = {})
    @taxons = []
    @products = []
    @initial_taxon = @current_taxon = options.delete(:taxon)
    super()
  end

  def parse_product(line)
    product = Product.new({ :name => line[2] })
    @products << product
    #@current_taxon.products << product
  end

  def parse_taxon(line)
    taxon = Taxon.new({ :name => line[0], :taxonomy_id => @current_taxon.taxonomy_id })
    @taxons << taxon
    @current_taxon = @current_root_taxon
    #@current_taxon.children << taxon
    @current_taxon = taxon
  end
end
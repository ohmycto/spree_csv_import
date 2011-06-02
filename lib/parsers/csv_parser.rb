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
        taxon = parse_taxon(line)
        @initial_taxon.children << taxon
        @current_root_taxon = @current_taxon = taxon
        self.to_taxon_state
      end
    end

    state :taxon do
      def parse(line)
        if line[0].blank?
          @current_taxon = @initial_taxon
          self.to_root_state
        elsif line[0] && !line[1]
          taxon = parse_taxon(line)
          @current_taxon.children << taxon
          puts "Added \"#{taxon.name}\" to taxons"
          @current_taxon = taxon
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
          taxon = parse_taxon(line)
          @current_root_taxon.children << taxon
          puts "Added \"#{taxon.name}\" to products"
          @current_taxon = taxon
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
      transition :taxon => :product, :root => :product
    end
  end

  def initialize(options = {})
    @taxons = []
    @products = []
    @initial_taxon = options.delete(:taxon)
    @current_taxon = @initial_taxon
    super()
  end

  def parse_product(line)
    product = Product.new({
      :name => line[CSV_PRODUCT_MAPPING[:name]],
      :description => line[CSV_PRODUCT_MAPPING[:description]],
      :price => line[CSV_PRODUCT_MAPPING[:price]].sub(' руб.', '').sub(',', '.').gsub(' ', '').to_f,
      :count_on_hand => line[CSV_PRODUCT_MAPPING[:count_on_hand]],
      :available_on => Date.today
    })
    image_urls = line[CSV_PRODUCT_MAPPING[:image_urls]]

    image_urls.split(' ').each do |url|
      product.images << Image.new(:attachment => download_remote_image(url))
    end if image_urls
    @products << product
    @current_taxon.products << product
    puts " -- Added product \"#{product.name}\" to database"
  end

  def parse_taxon(line)
    taxon = Taxon.find_by_name(line[0])
    taxon ||= Taxon.new({
      :name => line[0],
      :taxonomy_id => @current_taxon.taxonomy_id
    })
    @taxons << taxon
    taxon
  end
end

def download_remote_image(image_url)
  io = open(URI.parse(image_url))
  def io.original_filename; [base_uri.path.split('/').last, '.jpg'].join; end
  io.original_filename.blank? ? nil : io
rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
end
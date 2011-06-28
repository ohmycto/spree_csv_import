class Parsers::CsvParser

  attr_accessor :initial_taxon, :current_root_taxon, :parent_taxon, :current_taxon, :taxon_stack,
                :taxons, :updated_products, :inserted_products, :loaded_images_count, :threads

  state_machine :state, :initial => :title do
    state :title do
      def parse(line)
        self.to_root_state
      end
    end

    state :root do
      def parse(line)
        return if line[0].blank?
        taxon = parse_taxon(line)
        @initial_taxon.children << taxon
        @current_root_taxon = @current_taxon = @parent_taxon = taxon
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
          handle_taxon(taxon)
        else
          if @taxon_stack.children.size == 0
            @parent_taxon.children << @taxon_stack
          else
            @current_root_taxon.children << @taxon_stack
          end
          @taxon_stack = nil
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
          handle_taxon(taxon)
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
    @inserted_products = []
    @updated_products = []
    @loaded_images_count = 0
    
    #@taxon_stack = []
    @taxons = []
    @initial_taxon = options.delete(:taxon)
    @allow_insert = options.delete(:allow_insert) || true
    @current_taxon = @initial_taxon
    super()
  end

  private

  def download_remote_image(image_url)
    io = open(URI.parse(image_url))
    def io.original_filename; 'image.jpg'; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end

  def handle_taxon(taxon)
    unless @taxon_stack
      @taxon_stack = @current_taxon = taxon
    else
      @current_taxon.children << taxon
      @parent_taxon = @current_taxon
      @current_taxon = taxon
    end
  end

  def parse_product(line)
    nbsp = [194.chr, 160.chr].join
    product = Product.find_by_code(line[CSV_PRODUCT_MAPPING[:code]])

    print "product with code #{line[CSV_PRODUCT_MAPPING[:code]]} and name #{line[CSV_PRODUCT_MAPPING[:name]]}"

    if product
      puts " :: updating"
      product.update_attributes({
        :price => line[CSV_PRODUCT_MAPPING[:price]].sub(' руб.', '').sub(',', '.').gsub(nbsp, '').to_f,
        :on_hand => line[CSV_PRODUCT_MAPPING[:count_on_hand]].to_i
      })

      @updated_products << product
    elsif @allow_insert
      puts " :: inserting"
      product = Product.new({
        :code => line[CSV_PRODUCT_MAPPING[:code]],
        :name => line[CSV_PRODUCT_MAPPING[:name]],
        :description => line[CSV_PRODUCT_MAPPING[:description]],
        :price => line[CSV_PRODUCT_MAPPING[:price]].sub(' руб.', '').sub(',', '.').gsub(nbsp, '').to_f,
        :on_hand => line[CSV_PRODUCT_MAPPING[:count_on_hand]].to_i,
        :available_on => Date.today
      })

      image_urls = line[CSV_PRODUCT_MAPPING[:image_urls]]
      manufacturer = line[CSV_PRODUCT_MAPPING[:manufacturer]]

      unless manufacturer.blank?
        property = Property.find_by_name('manufacturer')
        property ||= Property.create(:name => 'manufacturer', :presentation => I18n.t('csv_import.manufacturer'))
        product.product_properties << ProductProperty.new(:property_id => property.id, :value => manufacturer)
      end

      image_urls.split(' ').each do |url|
        begin
          img = download_remote_image(url)
          if img && img.size > 200
            product.images << Image.new(:attachment => img)
            @loaded_images_count = @loaded_images_count + 1
            puts " -- loaded image \"#{url}\""
          end
        rescue
          puts " -- timeouted loaded image \"#{url}\""
        end
      end if image_urls

      @inserted_products << product
      @current_taxon.products << product
    end
  end

  def parse_taxon(line)
    taxon = Taxon.find_by_name(line[0])
    taxon ||= Taxon.new({
      :name => line[0],
      :taxonomy_id => @initial_taxon.taxonomy_id
    })
    @taxons << taxon
    taxon
  end
end


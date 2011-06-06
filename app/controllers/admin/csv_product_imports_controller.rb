# -*- coding: utf-8 -*-
class Admin::CsvProductImportsController < Admin::BaseController
  def index
    @csv_product_imports = CsvProductImport.order('created_at DESC')
  end

  def new
    @csv_product_import = CsvProductImport.new
  end

  def create
    @csv_product_import = CsvProductImport.new(params[:csv_product_import])
    @file = params[:file]
    @csv_product_import.filename = @file.original_filename

    if @csv_product_import.save
      File.open(File.join(Rails.root, 'tmp', @file.original_filename), 'w') do |file|
        file.write(@file.read)
      end

      command = %{cd #{Rails.root} && RAILS_ENV=#{Rails.env} rake spree_csv_import:parse_csv #{@csv_product_import.id} &}
      system command

      redirect_to admin_csv_product_imports_path
    else
      render :new
    end
  end

  def show
    @csv_product_import = CsvProductImport.find(params[:id])
  end
end

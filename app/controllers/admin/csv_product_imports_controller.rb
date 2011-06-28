# -*- coding: utf-8 -*-
class Admin::CsvProductImportsController < Admin::BaseController
  def index
    @csv_product_imports = CsvProductImport.order('created_at DESC')
  end

  def new
    @csv_product_import = CsvProductImport.new
  end

  def create
    parameters = params[:csv_product_import]
    @csv_product_import = CsvProductImport.new(parameters.merge({ :status => 'in_progress' }))
    @file = params[:file]
    @csv_product_import.filename = @file.original_filename

    if @csv_product_import.save
      File.open(File.join(Rails.root, 'tmp', @file.original_filename), 'w') do |file|
        file.write(@file.read)
      end

      command = %{cd #{Rails.root} && RAILS_ENV=#{Rails.env} rake spree_csv_import:parse_csv task_id=#{@csv_product_import.id}#{" update_only=1" if @csv_product_import.update_only} &}
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

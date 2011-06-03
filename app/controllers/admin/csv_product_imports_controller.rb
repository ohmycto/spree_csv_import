# -*- coding: utf-8 -*-
class Admin::CsvProductImportsController < Admin::BaseController
  def index
    @csv_product_imports = CsvProductImport.order('crated_at DESC')
  end

  def new
    @csv_product_import = CsvProductImport.new
  end

  def create
    @csv_product_import = CsvProductImport.new(params[:csv_product_import])
    if @csv_product_import.save
      respond_with(@csv_product_import)
    else
      render :new
    end
  end

  def show
    @csv_product_import = CsvProductImport.find(params[:id])
  end
end

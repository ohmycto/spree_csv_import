# -*- coding: utf-8 -*-
class Admin::CsvProductImportsController < Admin::BaseController
  def index
    @csv_imports = CsvProductImport.order('crated_at DESC')
  end
end

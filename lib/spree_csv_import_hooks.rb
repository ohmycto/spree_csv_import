class SpreeCsvImportHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_tabs do
    %(<%= tab(t('csv_import.csv_imports'), { :route => "admin_csv_product_imports" })  %>)
  end
end
class SpreeCsvImportHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_tabs do
    %(<%= tab(:csv_product_imports)  %>)
  end
end
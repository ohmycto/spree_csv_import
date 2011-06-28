class SpreeCsvImportHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_tabs do
    %(<%= tab(:csv_product_imports)  %>)
  end

  insert_before :admin_product_form_left do
    %(
      <p>
        <%= f.label :code, t("csv_import.code") %> <span class="required">*</span><br />
        <%= f.text_field :code, :class => 'fullwidth title'  %>
        <%= f.error_message_on :code %>
      </p>
    )
  end
end
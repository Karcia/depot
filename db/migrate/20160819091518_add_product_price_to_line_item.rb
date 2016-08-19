class AddProductPriceToLineItem < ActiveRecord::Migration[5.0]
  def up
    add_column :line_items, :price, :decimal, precision: 8, scale: 2

    LineItem.find_each do |lineitem|
      lineitem.update_attribute :price, lineitem.product.price
    end
  end

  def down
    remove_column :line_items, :price
  end
end

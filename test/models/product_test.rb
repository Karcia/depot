require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  include ActiveModel::Validations

  test "product attribute must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product must be positive" do
    product = Product.new(title: "Nowy produkt",
                          description: "jakis dlugi opis",
                          image_url: "czarny.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(
      title: "Nowa ksiazka",
      description: "super opis",
      image_url:  image_url,
      price: 1
    )
  end

  test "image_url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn`t be invalid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn`t be valid"
    end
  end

  test "product is not valid without a unique title" do
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end

  test "product title must be at least 10 characters long" do
    product = Product.new(title: "Some title",
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.valid?

    product.title = "Any title"
    assert product.invalid?
    min_title_size = Product.validators_on(:title).select { |v| v.class == ActiveModel::Validations::LengthValidator}.first.options[:minimum]
    assert_equal ["must have at least #{min_title_size} characters"], product.errors[:title]
  end
end
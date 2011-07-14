require 'spec_helper'

describe "products/new.html.erb" do
  before(:each) do
    assign(:product, stub_model(Product,
      :brand => nil,
      :thing => nil,
      :name => "MyString",
      :subname => "MyString",
      :desc => "MyText"
    ).as_new_record)
  end

  it "renders new product form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => products_path, :method => "post" do
      assert_select "input#product_brand", :name => "product[brand]"
      assert_select "input#product_thing", :name => "product[thing]"
      assert_select "input#product_name", :name => "product[name]"
      assert_select "input#product_subname", :name => "product[subname]"
      assert_select "textarea#product_desc", :name => "product[desc]"
    end
  end
end

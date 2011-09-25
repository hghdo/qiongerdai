require 'spec_helper'

describe "admin_releases/new.html.erb" do
  before(:each) do
    assign(:release, stub_model(Admin::Release).as_new_record)
  end

  it "renders new release form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => admin_releases_path, :method => "post" do
    end
  end
end

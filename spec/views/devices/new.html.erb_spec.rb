require 'spec_helper'

describe "devices/new.html.erb" do
  before(:each) do
    assign(:device, stub_model(Device).as_new_record)
  end

  it "renders new device form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => devices_path, :method => "post" do
    end
  end
end

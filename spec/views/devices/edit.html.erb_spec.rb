require 'spec_helper'

describe "devices/edit.html.erb" do
  before(:each) do
    @device = assign(:device, stub_model(Device))
  end

  it "renders the edit device form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => devices_path(@device), :method => "post" do
    end
  end
end

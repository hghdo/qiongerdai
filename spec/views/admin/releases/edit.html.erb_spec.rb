require 'spec_helper'

describe "admin_releases/edit.html.erb" do
  before(:each) do
    @release = assign(:release, stub_model(Admin::Release))
  end

  it "renders the edit release form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => admin_releases_path(@release), :method => "post" do
    end
  end
end

require 'spec_helper'

describe "admin_releases/show.html.erb" do
  before(:each) do
    @release = assign(:release, stub_model(Admin::Release))
  end

  it "renders attributes in <p>" do
    render
  end
end

require 'spec_helper'

describe "admin_releases/index.html.erb" do
  before(:each) do
    assign(:admin_releases, [
      stub_model(Admin::Release),
      stub_model(Admin::Release)
    ])
  end

  it "renders a list of admin_releases" do
    render
  end
end

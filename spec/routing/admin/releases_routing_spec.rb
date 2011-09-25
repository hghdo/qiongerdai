require "spec_helper"

describe Admin::ReleasesController do
  describe "routing" do

    it "routes to #index" do
      get("/admin_releases").should route_to("admin_releases#index")
    end

    it "routes to #new" do
      get("/admin_releases/new").should route_to("admin_releases#new")
    end

    it "routes to #show" do
      get("/admin_releases/1").should route_to("admin_releases#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin_releases/1/edit").should route_to("admin_releases#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin_releases").should route_to("admin_releases#create")
    end

    it "routes to #update" do
      put("/admin_releases/1").should route_to("admin_releases#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin_releases/1").should route_to("admin_releases#destroy", :id => "1")
    end

  end
end

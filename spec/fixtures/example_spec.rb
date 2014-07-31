describe "GET new" do

  context "for a guest" do
    it "redirects to root" {
      get :new
      expect(response).to redirect_to root_path
    }
  end
end

it "redirects to root" do
  get :new
  expect(response).to redirect_to root_path
end

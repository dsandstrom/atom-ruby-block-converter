context "for a guest" do
  it "redirects to root" {
    expect(response).to redirect_to root_path
  }
end

context "for a guest" do
  it "redirects to root" do
    expect(response).to redirect_to root_path
  end
end

it "redirects to root" do
  get :new, {}
  expect(response).to redirect_to root_path
end

it "updates the requested banner" do
  banner = FactoryGirl.create(:banner)
  # Assuming there are no other banners in the database, this
  # specifies that the Banner created on the previous line
  # receives the :update_attributes message with whatever params are
  # submitted in the request.
  Banner.any_instance.should_receive(:update).with({ "message" => "MyText" })
  put :update, {:id => banner.to_param, :banner => { "message" => "MyText" }}
end

it "destroys the requested banner" do
  banner = FactoryGirl.create(:banner)
  expect do
    delete :destroy, { :id => banner.to_param }
  }.to change(Banner, :count).by(-1)
end

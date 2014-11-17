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

it "updates the requested banner" {
  banner = FactoryGirl.create(:banner)
  Banner.any_instance.should_receive(:update).with({ "message" => "MyText" })
  put :update, {:id => banner.to_param, :banner => { "message" => "MyText" }}
}

it "destroys the requested banner" do
  banner = FactoryGirl.create(:banner)
  expect do
    delete :destroy, { :id => banner.to_param }
  end.to change(Banner, :count).by(-1)
end

it "destroys the requested banner" do
  banner = FactoryGirl.create(:banner)
  expect {
    delete :destroy, { :id => banner.to_param }
  }.to change(Banner, :count).by(-1)
end

it "updates the requested banner" {
  banner = FactoryGirl.create(:banner)
  Banner.any_instance.should_receive(:update).with({ "message" => "MyText" })
  put :update, {:id => banner.to_param, :banner => { "message" => "MyText" }}
}

it "does" do
  expect('soup').to eq { }
end

context "for tim" do
  it "redirects" {
    expect(response).to redirect
  }
end

# TODO: move cursor out of do
before do
  do
    var = 'noop'
  end
end

context "for tim" {
  it { expect(response).to redirect }
}

context "when nil" do
  before { @banner.message = nil }
end

it "assigns a newly created but unsaved banner as @banner" do
  # comment
  post :create, {"banner" => { "message" => "invalid value" }}#toDoEnd
end

{"banner" => { "message" => "invalid value" }}


let(:user) { FactoryGirl.create(:user) }

let(:valid_attributes) { { message: banner_bu } }

within "#var_#{var.id}" { should behave }

it do
  expect { Rake::Task['paper_trail:purge_old'].invoke }.to change(PaperTrail::Version, :count)
end

it do
  expect { q.invoke }.to change(Monkey, :count)
end

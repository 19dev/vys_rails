require 'spec_helper'

describe "nodes/index.html.erb" do
  before(:each) do
    assign(:nodes, [
      stub_model(Node,
        :title => "Title",
        :content => "MyText"
      ),
      stub_model(Node,
        :title => "Title",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of nodes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end

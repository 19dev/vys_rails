require 'spec_helper'

describe "nodes/edit.html.erb" do
  before(:each) do
    @node = assign(:node, stub_model(Node,
      :title => "MyString",
      :content => "MyText"
    ))
  end

  it "renders the edit node form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => nodes_path(@node), :method => "post" do
      assert_select "input#node_title", :name => "node[title]"
      assert_select "textarea#node_content", :name => "node[content]"
    end
  end
end

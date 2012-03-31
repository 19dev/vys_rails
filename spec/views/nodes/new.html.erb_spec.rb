require 'spec_helper'

describe "nodes/new.html.erb" do
  before(:each) do
    assign(:node, stub_model(Node,
      :title => "MyString",
      :content => "MyText"
    ).as_new_record)
  end

  it "renders new node form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => nodes_path, :method => "post" do
      assert_select "input#node_title", :name => "node[title]"
      assert_select "textarea#node_content", :name => "node[content]"
    end
  end
end

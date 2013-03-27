require 'spec_helper'

describe "blog_posts/index" do
  before(:each) do
    assign(:blog_posts, [
      stub_model(BlogPost,
        :title => "Title",
        :body => "MyText",
        :bloggable_id => 1,
        :bloggable_type => "Bloggable Type",
        :private => false
      ),
      stub_model(BlogPost,
        :title => "Title",
        :body => "MyText",
        :bloggable_id => 1,
        :bloggable_type => "Bloggable Type",
        :private => false
      )
    ])
  end

  it "renders a list of blog_posts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Bloggable Type".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end

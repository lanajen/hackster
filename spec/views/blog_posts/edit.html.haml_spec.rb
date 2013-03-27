require 'spec_helper'

describe "blog_posts/edit" do
  before(:each) do
    @blog_post = assign(:blog_post, stub_model(BlogPost,
      :title => "MyString",
      :body => "MyText",
      :bloggable_id => 1,
      :bloggable_type => "MyString",
      :private => false
    ))
  end

  it "renders the edit blog_post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", blog_post_path(@blog_post), "post" do
      assert_select "input#blog_post_title[name=?]", "blog_post[title]"
      assert_select "textarea#blog_post_body[name=?]", "blog_post[body]"
      assert_select "input#blog_post_bloggable_id[name=?]", "blog_post[bloggable_id]"
      assert_select "input#blog_post_bloggable_type[name=?]", "blog_post[bloggable_type]"
      assert_select "input#blog_post_private[name=?]", "blog_post[private]"
    end
  end
end

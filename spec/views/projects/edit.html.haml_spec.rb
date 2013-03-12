require 'spec_helper'

describe "projects/edit" do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :user_id => 1,
      :name => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", project_path(@project), "post" do
      assert_select "input#project_user_id[name=?]", "project[user_id]"
      assert_select "input#project_name[name=?]", "project[name]"
      assert_select "textarea#project_description[name=?]", "project[description]"
    end
  end
end

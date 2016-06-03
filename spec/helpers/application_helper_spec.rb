require 'spec_helper'

describe ApplicationHelper, type: :helper do

  before(:each) do
    @o1 = create :org

    textbox_content_with_missing_keys = "... [[OPTIONAL:SOME_MISSING_KEY_1]] ... [[OPTIONAL:SOME_MISSING_KEY_2]] ..."
    @b1 = create :text_block, raw_content: textbox_content_with_missing_keys
    ap html

  end

  it '#render_text_block' do

    u1 = create :user, org: @o1
    r1 = create :org_resource, org: @o1
    r2 = create :org_resource, org: @o1
    helper.stub(:current_user) { u1 }

    textbox_content = "... [[#{r1.org_key}]] ... [[#{r2.org_key}]] ..."
    b1 = create :text_block, raw_content: textbox_content

    html = helper.render_text_block(b1)
    ap textbox_content
    ap html

    expect(html).to include(r1.org_value)
    expect(html).to include r2.org_value

    b2 = create :text_block, raw_content: "... [[#{r1.org_key}1]] ..."
    html = helper.render_text_block(b2)
    expect(html).to include 'content placeholder'
  end

  it '#optional key should be filled with value if value available' do
    u1 = create :user, :student, org: @o1
    r1 = create :optional_org_resource, org: @o1
    r2 = create :optional_org_resource, org: @o1

    helper.stub(:current_user) { u1 }

    textbox_content = "... [[#{r1.org_key}]] ... [[#{r2.org_key}]] ..."
    b1 = create :text_block, raw_content: textbox_content

    html = helper.render_text_block(b1)

    ap textbox_content
    ap html

    expect(html).to include r1.org_value
    expect(html).to include r2.org_value

  end

  it '#missing optional key should show CONTENT PLACEHOLDER for admin' do
    u_admin = create :user, :admin, org: @o1
    helper.stub(:current_user) { u_admin }
    html = helper.render_text_block(@b1)
    expect(html).to include 'content placeholder'
  end
  it '#missing optional key should show CONTENT PLACEHOLDER for content_managers' do
    u_content_manager = create :user, :manager, org: @o1
    helper.stub(:current_user) { u_content_manager }
    html = helper.render_text_block(@b1)
    expect(html).to include 'content placeholder'
  end
  it '#missing optional key should show blank span for student' do
    u_student = create :user, :student, org: @o1
    helper.stub(:current_user) { u_student }
    html = helper.render_text_block(@b1)
    expect(html).to_not include 'content placeholder'
  end
  it '#missing optional key should show CONTENT PLACEHOLDER for user_managers' do
    u_user_manager = create :user, :content_manager, org: @o1
    helper.stub(:current_user) { u_user_manager }
    html = helper.render_text_block(@b1)
    expect(html).to include 'content placeholder'
  end
end

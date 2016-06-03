require 'spec_helper'

describe UserDetail do
  let(:student) { create(:user, :student) }

  subject do
    student.user_detail
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  it "should create with random id" do
    u1 = create(:user, :student).user_detail
    u2 = create(:user, :student).user_detail
    u3 = create(:user, :student).user_detail

    pp u1.id, u2.id, u3.id

    (u2.id - u1.id).should_not == (u3.id - u2.id)
  end

  it 'should use hstore' do
    subject.user_data['aaa'] = 'bbb'
    subject.user_data_will_change!
    subject.save!
    subject.reload
    #pp subject
    subject.user_data['aaa'].should == 'bbb'
  end

  it 'should create female' do
    ud = create(:user_detail, :female)
    ud.reload
    ud.female?.should == true
    ud.male?.should == false
  end

  it 'should return race_for_select' do
    #pp UserDetail.race_for_select
    UserDetail.race_for_select.size.should == UserDetail::RACES.count
  end

  it 'should set race by race_map' do
    name = 'Black'
    value = 'black'

    subject.race_map = name
    subject.race.should == value

    subject.race = value
    subject.race_map.should == name
  end

  it 'should set race by multi_race_map' do
    subject.race.should_not == 'black'

    subject.multi_race_map = ["", "Black", "White"]
    subject.race.should == 'black'

    subject.multi_race_map = ["Asian - Far East", "Hispanic/Latino"]
    subject.race.should == 'hispanic'

    subject.multi_race_map = ["Asian - Indian Subcontinent", "Asian - Southeast"]
    subject.race.should == 'asian'

    subject.multi_race_map = FACE_CONFIG['race_identifiers'].keys
    subject.race.should == 'black'
  end

  context 'filter' do
    it 'should filter by email' do
      u1 = create(:user, :student, email: 'aaa@aa.aa')
      u2 = create(:user, :student, email: 'aab@bb.bb')

      UserDetail.filter(email: 'aaA').should include(u1.user_detail)
      UserDetail.filter(email: 'aa').should include(u1.user_detail, u2.user_detail)
      UserDetail.filter(email: 'bb').should include(u2.user_detail)
    end

    it 'should filter by name' do
      u1 = create(:user, :student, first_name: 'aaa', last_name: 'bbb')
      u2 = create(:user, :student, first_name: 'aab', last_name: 'ccc')

      UserDetail.filter(name: 'aaa').should include(u1.user_detail)
      UserDetail.filter(name: 'aaa').should_not include(u2.user_detail)
      UserDetail.filter(name: 'aa').should include(u1.user_detail, u2.user_detail)
      UserDetail.filter(name: 'cc').should include(u2.user_detail)
      UserDetail.filter(name: 'cc').should_not include(u1.user_detail)
    end

    it 'should filter by org' do
      o1 = create :org
      o2 = create :org

      u1 = create(:user, :student, org: o1)
      u2 = create(:user, :student, org: o1)
      u3 = create(:user, :student, org: o2)

      UserDetail.filter(org: o1.id).should include(u1.user_detail, u2.user_detail)
      UserDetail.filter(org: o1.id).should_not include(u3.user_detail)
      UserDetail.filter(org: o2.id).should include(u3.user_detail)
      UserDetail.filter(org: o2.id).should_not include(u1.user_detail, u2.user_detail)
    end
  end

  it 'should update_details' do
    o1 = create :org
    o2 = create :org
    u1 = create(:user, :student, org: o1)

    params = { email: 'aa@aa.aa', org: o2.id }
    u1.user_detail.update_details params

    u1.reload
    u1.email.should == params[:email]
    u1.org_id.should == params[:org]

    # params = { gender: 'female', race: 'black' }
    # u1.user_detail.update_details params
    #
    # u1.reload
    # u1.user_detail.gender.should == params[:gender]
    # u1.user_detail.race.should == params[:race]
  end

  context 'registration_state' do
    it 'should init state_machine' do
      subject.registration_state = 'require_name'
      subject.user = create :user, first_name: 'aaa', last_name: 'bbb'
      subject.registration_state.should == 'require_name'
      subject.require_name?.should == true

      subject.apply_student_name!
    end
  end

  it 'should return config' do
    d1 = {
      'Asian - Southeast' => 'asian',
      'Asian - Far East' => 'asian',
      'Asian - Indian Subcontinent' => 'indian',
      'Black' => 'black',
      'Hispanic/Latino' => 'hispanic',
      'Middle Eastern' => 'middle eastern',
      'Native American' => 'hispanic',
      'White' => 'white'
    }

    # RACE_SHUFFLES
    d2 = {
      "white" => { 1 => "black", 2 => "asian", 3 => "middle eastern" },
      "black" => { 1 => "asian", 2 => "white", 3 => "middle eastern" },
      "asian" => { 1 => "black", 2 => "white", 3 => "middle eastern" },
      "middle eastern" => { 1 => "black", 2 => "asian", 3 => "white" },
      "indian" => { 1 => "black", 2 => "white", 3 => "asian" },
      "hispanic" => { 1 => "black", 2 => "white", 3 => "asian" },
    }.freeze
    pp YAML::dump(d1)
    pp YAML::dump(d2)

    FACE_CONFIG['race_shuffles'].should_not be_empty
    FACE_CONFIG['race_identifiers'].should_not be_empty
    FACE_CONFIG['race_weights'].should_not be_empty
  end

  it 'should update_pledge_of_inclusion' do
    subject.pledge_of_inclusion_applied?.should == false

    subject.update_pledge_of_inclusion(fb_shared: true)
    subject.reload
    ap subject.user_data
    subject.pledge_of_inclusion_fb_shared.should == 'true'
    subject.pledge_of_inclusion_applied?.should == true
    subject.pledge_of_inclusion_facebook?.should == false

    subject.update_pledge_of_inclusion(fb_shared: false)
    subject.reload
    ap subject.user_data
    subject.pledge_of_inclusion_fb_shared.should == 'false'
    subject.pledge_of_inclusion_facebook?.should == true
  end

end

require 'spec_helper'

describe UserEvent do
  let(:student) { create(:user, :student, :with_course) }
  let(:course) { student.courses.first }

  subject do
    create :user_event, user: student, course: course, event_type: 'course_begin'
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
  end

  describe 'validate' do
    it 'course' do
      subject.course = create :course
      subject.should be_invalid
    end

    it 'learning_module' do
      subject.learning_module = create :learning_module
      subject.learning_module.should_not == nil
      subject.should be_invalid

      subject.learning_module = course.learning_modules.first
      subject.learning_module.should_not == nil
      subject.should be_valid
    end

    it 'lesson' do
      subject.learning_module = course.learning_modules.first

      subject.lesson = create :lesson
      subject.lesson.should_not == nil
      subject.should be_invalid

      subject.lesson = subject.learning_module.lessons.first
      subject.lesson.should_not == nil
      subject.should be_valid
    end
    
    it 'content_page' do
      subject.learning_module = course.learning_modules.first
      subject.lesson = subject.learning_module.lessons.first

      subject.content_page = create :content_page
      subject.content_page.should_not == nil
      subject.should be_invalid
    
      subject.content_page = subject.lesson.content_pages.first
      subject.content_page.should_not == nil
      subject.should be_valid
    end
  end

  describe '.student_activity_events' do
    let(:org) { create :org }
    let(:student) { create(:user, :student, :with_simple_course, org: org) }

    let(:course) { student.courses.first }
    let(:learning_module) { course.learning_module_by_position(1) }
    let(:lesson) { learning_module.lesson_by_position(1) }
    let(:content_page1) { lesson.content_page_by_position(1) }
    let(:content_page2) { lesson.content_page_by_position(2) }
    let(:content_page3) { lesson.content_page_by_position(3) }

    let!(:e1) { create :user_event, user: student, course: course, event_type: 'course_begin' }
    let!(:e2) { create :user_event, user: student, course: course, event_type: 'learning_module_begin', learning_module: learning_module }
    let!(:e3) { create :user_event, user: student, course: course, event_type: 'lesson_begin', learning_module: learning_module, lesson: lesson }
    let!(:e4) { create :user_event, user: student, course: course, event_type: 'content_page_begin', learning_module: learning_module, lesson: lesson, content_page: content_page1 }
    let!(:e5) { create :user_event, user: student, course: course, event_type: 'content_page_end', learning_module: learning_module, lesson: lesson, content_page: content_page1 }
    let!(:e6) { create :user_event, user: student, course: course, event_type: 'lesson_end', learning_module: learning_module, lesson: lesson }
    let!(:e7) { create :user_event, user: student, course: course, event_type: 'learning_module_end', learning_module: learning_module }
    let!(:e8) { create :user_event, user: student, course: course, event_type: 'course_end' }

    let(:org2) { create :org }
    let(:student2) { create(:user, :student, :with_simple_course, org: org2) }
    let(:course2) { student2.courses.first }
    let(:learning_module2) { course2.learning_module_by_position(1) }

    let!(:e27) { create :user_event, user: student2, course: course2, event_type: 'learning_module_end', learning_module: learning_module2 }
    let!(:e28) { create :user_event, user: student2, course: course2, event_type: 'course_end' }

    it 'for specific org' do
      all = UserEvent.student_activity_events(org)
      ap all
      all.count.should == 3
      all.should include(e1, e7, e8)
    end

    it 'for all orgs' do
      all = UserEvent.student_activity_events
      ap all
      all.count.should == 5
      all.should include(e1, e7, e8, e27, e28)
    end
  end

  describe 'manager_activity' do
    let(:manager) { create :user, :manager, org: student.org }

    it 'validate' do
      e1 = build :user_event, user: manager, event_type: 'manager_activity'
      e1.should be_invalid
      e1.event_data['user_id'] = student.id
      e1.should be_valid

      e1.save
      e1.reload
      ap e1.event_data
      e1.event_data['user_id'].should == student.id.to_s
    end

    it '.create_manager_activity' do
      e1 = UserEvent.create_manager_activity(manager, student, 'created')
      ap e1
      e1.should be_persisted
    end
  end

end

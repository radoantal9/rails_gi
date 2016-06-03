require 'spec_helper'

describe Course do
  let(:student) { student = create(:user, :student, :with_course) }
  let(:course) { student.courses.first }
  let(:learning_module) { course.learning_module_by_position(1) }
  let(:learning_module2) { course.learning_module_by_position(2) }
  let(:learning_module3) { course.learning_module_by_position(3) }
  let(:lesson1) { learning_module.lesson_by_position(1) }
  let(:lesson2) { learning_module.lesson_by_position(2) }
  let(:lesson3) { learning_module.lesson_by_position(3) }
  let(:content_page11) { lesson1.content_page_by_position(1) }
  let(:content_page12) { lesson1.content_page_by_position(2) }
  let(:content_page13) { lesson1.content_page_by_position(3) }
  let(:content_page33) { lesson3.content_page_by_position(3) }

  subject do
    course
  end

  it 'subject' do
    subject.should be_a described_class
    ap subject
    # subject.print_pages
    subject.learning_modules.count.should == 3
  end

  it '#learning_module_by_position' do
    #pp subject.learning_modules
    subject.learning_module_by_position(1).should == subject.learning_modules.first
    subject.learning_module_by_position(1).should_not == subject.learning_module_by_position(2)
  end

  it '#page_count' do
    #subject.print_pages
    subject.page_count.should == 21
  end

  it '#get_page' do
    subject.get_page(1).page.should == subject.learning_module_by_position(1)
    subject.get_page(6).page.should == subject.learning_module_by_position(1).lesson_by_position(2)
    subject.get_page(10).page.should == subject.learning_module_by_position(1).lesson_by_position(3).content_page_by_position(3)

    subject.get_page(11).page.should == subject.learning_module_by_position(2)
    subject.get_page(15).page.should == subject.learning_module_by_position(3).lesson_by_position(1).content_page_by_position(2)

    subject.get_page(22).should == nil
  end

  it '#descendants' do
    subject.descendants(3) do |obj, page|
      pp "#{page} #{obj.inspect}"
    end
  end

  describe 'scope' do
    it 'by_enrollment_code' do
      code1 = create :orgs_course
      code2 = create :orgs_course
      Course.by_enrollment_code(code1.enrollment_code).should include(code1.course)
      Course.by_enrollment_code(code1.enrollment_code).should_not include(code2.course)
    end

    it 'by_org' do
      o1 = create :org
      c1 = create :course
      c2 = create :course
      create :orgs_course, org: o1, course: c1
      create :orgs_course, org: o1, course: c2

      o2 = create :org
      c3 = create :course
      create :orgs_course, org: o2, course: c3

      Course.by_org(o1).should include(c1, c2)
      Course.by_org(o1).should_not include(c3)

      Course.by_org(o2).should include(c3)
      Course.by_org(o2).should_not include(c1, c2)
    end
  end

  describe '#log_page_event' do
    before :each do
      # course.print_pages
    end

    it 'for learning_module1' do
      course.log_page_event(student, course.get_page(1))
      ev = UserEvent.all
      ev.count.should == 2
      ev[1].event_type.should == 'course_begin'
      ev[0].event_type.should == 'learning_module_begin'
      ev[0].learning_module.should == learning_module

      course.current_page(student).should == 1
    end

    it 'for lesson1' do
      course.log_page_event(student, course.get_page(2))
      ev = UserEvent.all
      ev.count.should == 1
      ev[0].event_type.should == 'lesson_begin'
      ev[0].lesson.should == lesson1

      course.current_page(student).should == 2
    end

    it 'for content_page11' do
      course.log_page_event(student, course.get_page(3))
      ev = UserEvent.all
      ev.count.should == 1
      ev[0].event_type.should == 'content_page_begin'
      ev[0].content_page.should == content_page11

      course.current_page(student).should == 3
    end

    it 'for content_page12' do
      course.log_page_event(student, course.get_page(4))
      ev = UserEvent.all
      ev.count.should == 2
      ev[1].event_type.should == 'content_page_end'
      ev[1].content_page.should == content_page11
      ev[0].event_type.should == 'content_page_begin'
      ev[0].content_page.should == content_page12

      course.current_page(student).should == 4
    end

    it 'for lesson2' do
      course.log_page_event(student, course.get_page(6))
      ev = UserEvent.all
      ev.count.should == 3
      ev[2].event_type.should == 'content_page_end'
      ev[2].content_page.should == content_page13
      ev[1].event_type.should == 'lesson_end'
      ev[1].lesson.should == lesson1
      ev[0].event_type.should == 'lesson_begin'
      ev[0].lesson.should == lesson2

      course.current_page(student).should == 6
    end

    it 'for lesson3' do
      course.log_page_event(student, course.get_page(7))
      ev = UserEvent.all
      ev.count.should == 2
      ev[1].event_type.should == 'lesson_end'
      ev[1].lesson.should == lesson2
      ev[0].event_type.should == 'lesson_begin'
      ev[0].lesson.should == lesson3

      course.current_page(student).should == 7
    end

    it 'for learning_module2' do
      course.log_page_event(student, course.get_page(11))
      ev = UserEvent.all
      ev.count.should == 4
      ev[3].event_type.should == 'content_page_end'
      ev[3].content_page.should == content_page33
      ev[2].event_type.should == 'lesson_end'
      ev[2].lesson.should == lesson3
      ev[1].event_type.should == 'learning_module_end'
      ev[1].learning_module.should == learning_module
      ev[0].event_type.should == 'learning_module_begin'
      ev[0].learning_module.should == learning_module2

      course.current_page(student).should == 11
    end

    it 'for learning_module3' do
      course.log_page_event(student, course.get_page(12))
      ev = UserEvent.all
      ev.count.should == 2
      ev[1].event_type.should == 'learning_module_end'
      ev[1].learning_module.should == learning_module2
      ev[0].event_type.should == 'learning_module_begin'
      ev[0].learning_module.should == learning_module3

      course.current_page(student).should == 12
    end

    describe 'same page' do
      it 'for learning_module' do
        course.log_page_event(student, course.get_page(1))
        course.log_page_event(student, course.get_page(1))

        ev = UserEvent.all
        ev.count.should == 2
      end

      it 'for lesson1' do
        course.log_page_event(student, course.get_page(2))
        course.log_page_event(student, course.get_page(2))

        ev = UserEvent.all
        ev.count.should == 1
      end

      it 'for content_page11' do
        course.log_page_event(student, course.get_page(3))
        course.log_page_event(student, course.get_page(3))

        ev = UserEvent.all
        ev.count.should == 1
      end
    end
  end

  describe '#page_for_parents' do
    it 'good' do
      params = { learning_module: learning_module, lesson: lesson1, content_page: content_page12 }
      course.page_for_parents(params).page_num.should == 4
      params = { learning_module: learning_module, lesson: lesson1, content_page: content_page13 }
      course.page_for_parents(params).page_num.should == 5
      params = { learning_module: learning_module, lesson: lesson2 }
      course.page_for_parents(params).page_num.should == 6
      params = { learning_module: learning_module, lesson: lesson3, content_page: content_page33 }
      course.page_for_parents(params).page_num.should == 10
      params = { learning_module: learning_module3 }
      course.page_for_parents(params).page_num.should == 12
    end

    it 'bad' do
      params = {}
      course.page_for_parents(params).should == nil
      params = { learning_module: learning_module2, lesson: lesson1 }
      course.page_for_parents(params).should == nil
    end
  end

  describe '#current_page' do
    def events
      course.user_events.by_user(student)
    end

    it 'not started' do
      events.should be_empty
      course.current_page(student).should == 1
    end

    it 'learning_module' do
      course.log_page_event(student, course.get_page(1))
      events.count.should == 2
      course.current_page(student).should == 1
    end

    it 'lesson' do
      course.log_page_event(student, course.get_page(2))
      course.current_page(student).should == 2
    end

    it 'content_page' do
      course.log_page_event(student, course.get_page(3))
      events.count.should == 1
      course.current_page(student).should == 3
      course.log_page_event(student, course.get_page(4))
      events.count.should == 3
      course.current_page(student).should == 4
      course.log_page_event(student, course.get_page(5))
      events.count.should == 5
      course.current_page(student).should == 5
    end
  end

  it '#current_learning_module' do
    # course.print_pages
    course.current_learning_module(student).should == nil

    course.log_page_event(student, course.get_page(1))
    course.current_learning_module(student).should == learning_module

    course.log_page_event(student, course.get_page(11))
    course.current_learning_module(student).should == learning_module2

    course.log_page_event(student, course.get_page(12))
    course.current_learning_module(student).should == learning_module3

    course.complete(student)
    course.current_learning_module(student).should == nil
  end

  describe '#is_content_page_completable?' do
    it 'for page with unfinished quiz' do
      content_page11.quizzes << create(:quiz)
      course.is_content_page_completable?(student, content_page11).should == false
    end

    it 'for page with unfinished question' do
      content_page11.ungraded_questions << create(:question, content: QuestionXMLSamples::ESSAY)
      course.is_content_page_completable?(student, content_page11).should == false
    end
  end

  describe '#page_available?' do
    it 'good' do
      course.page_available?(student, course.get_page(1)).should == true
      course.page_available?(student, course.get_page(2)).should == false
    end

    it 'bad' do
      course.page_available?(student, nil).should == false
    end
  end

  it '#generate_course_pages' do
    #subject.print_pages
    subject.course_pages.destroy_all
    subject.course_pages.should be_empty

    subject.generate_course_pages
    #ap subject.course_pages

    parent = {}
    subject.course_pages.each do |page|
      #pp page
      parent[page.page_type] = page.page_num

      case page.page_num
        when 1
          page.learning_module.should_not be_nil
          page.lesson.should be_nil
          page.content_page.should be_nil
          page.learning_module_page_num.should == 1
          page.lesson_page_num.should be_nil
          page.content_page_num.should be_nil
        when 2
          page.learning_module.should_not be_nil
          page.lesson.should_not be_nil
          page.content_page.should be_nil
          page.learning_module_page_num.should == 1
          page.lesson_page_num.should == 2
          page.content_page_num.should be_nil
        when 3
          page.learning_module.should_not be_nil
          page.lesson.should_not be_nil
          page.content_page.should_not be_nil
          page.learning_module_page_num.should == 1
          page.lesson_page_num.should == 2
          page.content_page_num.should == 3
        when 8
          page.learning_module_page_num.should == 1
          page.lesson_page_num.should == 7
          page.content_page_num.should == 8
        when 17
          page.learning_module.should == learning_module3
          page.learning_module_page_num.should == 12
          page.lesson_page_num.should == 17
          page.content_page_num.should == nil
      end
    end

    id = subject.course_pages.first.id
    # no change
    subject.generate_course_pages
    subject.course_pages.first.id.should == id
  end

  describe 'report' do
    let(:student) { student = create(:user, :student, :with_course) }
    let(:course) { student.courses.first }

    it '#user_completion' do
      # subject.print_pages
      course.user_completion(student).should == 0
      course.user_completion(student, learning_module).should == 0
      course.user_completion(student, learning_module2).should == 0

      course.log_page_complete_event(student, course.get_page(3), course.get_page(2))
      course.user_completion(student).should == 8
      course.user_completion(student, learning_module).should == 16

      course.log_page_complete_event(student, course.get_page(4), course.get_page(3))
      course.log_page_complete_event(student, course.get_page(5), course.get_page(4))
      course.user_completion(student).should == 25
      course.user_completion(student, learning_module).should == 50

      course.log_page_complete_event(student, course.get_page(8), course.get_page(7))
      course.log_page_complete_event(student, course.get_page(9), course.get_page(8))
      course.log_page_complete_event(student, course.get_page(10), course.get_page(9))
      course.user_completion(student).should == 50
      course.user_completion(student, learning_module).should == 100

      course.log_page_complete_event(student, course.get_page(14), course.get_page(13))
      course.user_completion(student).should == 58
      course.user_completion(student, learning_module).should == 100
      course.user_completion(student, learning_module3).should == 16
    end

    it '#learning_module_page' do
      #course.print_pages
      m1 = course.learning_module_by_position(1)
      m2 = course.learning_module_by_position(2)
      m3 = course.learning_module_by_position(3)
      course.learning_module_page(m1).page_num.should == 1
      course.learning_module_page(m2).page_num.should == 11
      course.learning_module_page(m3).page_num.should == 12
    end

    it '#next_learning_module_page' do
      #course.print_pages
      course.next_learning_module_page(1).page_num.should == 11
      course.next_learning_module_page(11).page_num.should == 12
      course.next_learning_module_page(12).should == nil
    end
  end

  it '#course_quizzes' do
    #pp subject.course_quizzes
    subject.course_quizzes.count.should == 8
  end

  it '#course_quiz_ids' do
    #subject.print_pages

    new_page = create :content_page, :with_quiz
    #pp new_page.own_quiz_ids
    subject.learning_modules.first.lessons.first.content_pages << new_page # 1 quiz

    all = subject.course_quiz_ids
    #pp all
    all[:quiz_ids].count.should == 8 + 1
    all[:question_ids].count.should == 0
  end
end

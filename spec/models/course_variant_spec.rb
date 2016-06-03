require 'spec_helper'

describe CourseVariant do
  let(:course1) { create :course, :with_modules }
  let(:m1) { course1.learning_module_by_position(1) }
  let(:m2) { course1.learning_module_by_position(2) }
  let(:l1) { m1.lesson_by_position(1) }
  let(:l2) { m1.lesson_by_position(2) }
  let(:l3) { m1.lesson_by_position(3) }
  let(:p1) { l1.content_page_by_position(1) }
  let(:p2) { l1.content_page_by_position(2) }
  let(:p3) { l1.content_page_by_position(3) }

  subject do
    course_structure = {
      m2.id => [l1.id, l2.id],
      m1.id => [l3.id]
    }

    create :course_variant, course: course1, course_structure: course_structure
  end

  it 'subject' do
    # course1.print_pages
    subject.should be_a described_class
    ap subject.course_structure
    ap subject.course_structure_cache
  end

  it '#find_course_object' do
    subject.find_course_object(m1.id).should == m1
    subject.find_course_object(m2.id, l1.id).should == l1
    subject.find_course_object(m2.id, l1.id, p1.id).should == p1
  end

  it '#find_next_course_object' do
    subject.find_next_course_object(1, learning_module_id: m2.id).should == { learning_module_id: m2.id, lesson_id: l1.id }
    subject.find_next_course_object(-1, learning_module_id: m1.id).should == { learning_module_id: m2.id, lesson_id: l2.id }

    subject.find_next_course_object(1, learning_module_id: m2.id, lesson_id: l1.id).should == { learning_module_id: m2.id, lesson_id: l1.id, content_page_id: p1.id }
    subject.find_next_course_object(1, learning_module_id: m2.id, lesson_id: l2.id).should == { learning_module_id: m1.id }
    subject.find_next_course_object(-1, learning_module_id: m2.id, lesson_id: l2.id).should == { learning_module_id: m2.id, lesson_id: l1.id, content_page_id: p3.id }

    subject.find_next_course_object(1, learning_module_id: m2.id, lesson_id: l1.id, content_page_id: p1.id).should == { learning_module_id: m2.id, lesson_id: l1.id, content_page_id: p2.id }
    subject.find_next_course_object(1, learning_module_id: m2.id, lesson_id: l1.id, content_page_id: p3.id).should == { learning_module_id: m2.id, lesson_id: l2.id }
  end
end

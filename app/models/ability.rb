class Ability

  # Todo: Integrate with role-model
  # http://www.phase2technology.com/blog/authentication-permissions-and-roles-in-rails-with-devise-cancan-and-role-model/

  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    if user
      can :pledge_of_inclusion, User, id: user.id

      can :read, WordDefinition

      if user.is? :admin
        can :manage, :all
        return
      end

      if user.is? :user_manager
        # Show only responses for manager's org students
        # can [:index, :see_org_users], QuestionResponse
        #
        # can :see_response_user, QuestionResponse do |question_response|
        #   question_response.question_privacy != :confidential_anonymous
        # end
        #
        # can :see_response_content, QuestionResponse do |question_response|
        #   question_response.question_privacy != :confidential_private
        # end

        # Manage own students only, create users manually, enroll students to courses
        can [:read, :update, :comment, :email], User do |student|
          student.is_student? && student.org == user.org
        end

        can :create, User

        can :index, :search

        can [:student_certificate], User do |student|
          student.org == user.org
        end

        # Update user details
        can :manage, UserDetail do |detail|
          detail.user.is_student? && detail.user.org == user.org
        end

        # Subscribe/unsubscribe
        can :notifications, User, id: user.id

        # Org courses
        can :read, Reminder do |reminder|
          reminder.orgs_course.org == user.org
        end
        can [:read, :resend, :activate], Invitation do |inv|
          inv.orgs_course.org == user.org
        end

        can [:create_reminder, :create_invitation, :create_survey], Course do |course|
          user.org.courses.include? course
        end

        can [:read, :report_summary, :report_aging,
             :email_index, :email_show, :update_org_mails, :course_users
            ], Org, id: user.org_id

        can :manage, OrgResource, org_id: user.org_id

        can :update_course_mails, OrgsCourse, org_id: user.org_id
      end

      if user.is? :content_manager
        # Edit course related content (questions, quizzes, content_pages, lessons, etc.)
        #TODO own course
        can :manage, LearningModule
        can :manage, Lesson
        can :manage, ContentPage
        can :manage, Quiz
        can :manage, Question
        can :index, :search 

        can :all, Course
        # can :see_all_users, QuestionResponse

        can :manage, WordDefinition
      end

      if user.is?(:user_manager) || user.is?(:content_manager)
        # Content_managers, user_managers and admins should be able to see user submissions
        # can :reports, QuestionResponse

        # Managers can see the list of courses (in #index), but can only #show courses their org is registered in (course_org table)
        can :index, Course
        can :show, Course do |course|
          course.orgs.include? user.org
        end

        can [:show], :dashboard
      end

      if user.is? :student
        # Student
        can [:show, :edit, :update, :name, :anonymous], User do |that_user|
          user.is_student? && user == that_user
        end

        can [:show], :dashboard

        can [:show, :update], UserDetail do |user_detail|
          user.is_student? && user == user_detail.user
        end

        # Student can only see their enrolled courses
        can [:index, :show, :start, :page, :module_completed, :module_finish, :continue, :complete, :rate_lesson, :progress_stats], Course do |course|
          user.is_student? && user.courses.include?(course)
        end

        can [:show, :start, :page], CourseVariant

        can [:show, :grade, :prev], Quiz

        can [:show, :grade], Question do |question|
          # TODO student in course
          true
        end

        can [:index, :create], QuestionResponse
        can [:show, :edit, :update, :reedit, :guess, :see_response_user, :see_response_content], QuestionResponse do |question_response|
          question_response.user == user
        end

        can [:self_journal, :self_certificate], User

        can :show, WordDefinition
      end
    end
  end
end

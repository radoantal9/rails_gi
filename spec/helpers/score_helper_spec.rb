require 'spec_helper'
require 'score_helper'

describe 'computes score' do

  before (:each) do
    @sh = ScoreHelper.new
  end

  context "multiple choice question" do
    it 'returns a score of 0 if all answers are wrong for a 5 option question' do
      total_number_of_choices = 5
      correct_answer  = %w[a b c]
      given_answer    = %w[d e]

      @sh.multiple_choice(given_answer, correct_answer, total_number_of_choices).should be_eql(0.0)

    end

    it 'returns a score of 1.0 if given options are all correct ' do
      total_number_of_choices = 6
      correct_answer  = %w[a b c]
      given_answer    = %w[b c a]

      @sh.multiple_choice(given_answer, correct_answer, total_number_of_choices).should be_eql(1.0)
    end

    # multiple_choice()given, correct, number of choices, options)
    it 'returns a score of 6/8 if of 8 options 2 are explitcly correct and 6 implicitly' do
      # this example has 8 options, of given answers 6 are right, 2 explitcy and 4 implicity
      @sh.multiple_choice(%w[a b], %w[a b c d], 8).should be_eql(6.0/8)
    end

    it 'returns a score of 0 if all given options are blank, no freebees for implicitly unchecked correct answers' do
      @sh.multiple_choice(%w[], %w[a b c d], 8).should be_eql(0.0)
    end

    it 'penalizes with a score of 0 if all the options are "checked"' do
      @sh.multiple_choice(%w[a b c d e], %w[a b c], 5).should be_eql(0.0)
    end

  end

end
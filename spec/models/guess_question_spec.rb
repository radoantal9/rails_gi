require 'spec_helper'

# response(question, item, answer)
xml = %(

<question>
  <statement text='The United States is one of the most diverse countries in the world. Below is a list of categories that make up our diverse society. Guess what percentage of the U.S. population makes up each of the following categories. Choose a percentage between 0% and 100%.'/>

  <options type='guess'>
    <range difference='20%' text='twenty' />
    <range difference='50%' text='fifty' />
    <range default='true' text='default' />
  </options>

  <item type='slider' min='0' max='100' text='slider' answer='100'/>
  <item type='number' text='number' answer='100' /> 
</question>
)

describe GuessQuestion do
  describe "response" do
    describe "should include the correct range" do
      before :each do
        @question = create(:question, title: "Guess Question", content: xml, question_type: "guess")
      end

      it "for slider" do
        text = 'slider'
        item = @question.xmlnode.xpath("//question/item[@text='" + text.gsub("'", "\\'") + "']").first
        GuessQuestion.response(@question, item, "75")[:range_text].should eq "fifty"
        GuessQuestion.response(@question, item, "90")[:range_text].should eq "twenty"
        GuessQuestion.response(@question, item, "20")[:range_text].should eq "default"
        GuessQuestion.response(@question, item, "0")[:correct].should eq '100'
      end

      it "for number" do
        text = 'number'
        item = @question.xmlnode.xpath("//question/item[@text='" + text.gsub("'", "\\'") + "']").first
        GuessQuestion.response(@question, item, "75")[:range_text].should eq "fifty"
        GuessQuestion.response(@question, item, "90")[:range_text].should eq "twenty"
        GuessQuestion.response(@question, item, "20")[:range_text].should eq "default"
        GuessQuestion.response(@question, item, "0")[:correct].should eq '100'
      end
    end
  end
end

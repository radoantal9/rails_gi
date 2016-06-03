# XML strings for questions and answers

# Creates following constants for use in tests
# QuestionXMLSamples::SINGLE
# QuestionXMLSamples::SINGLE_CHOICE_CORRECT_ANSWERS

# QuestionXMLSamples::MULTIPLE
# QuestionXMLSamples::MULTIPLE_CHOICE_CORRECT_ANSWERS

# QuestionXMLSamples::TRUEFALSE
# QuestionXMLSamples::TRUEFALSE_CORRECT_ANSWERS

# QuestionXMLSamples::MATCH
# QuestionXMLSamples::MATCH_CORRECT_ANSWERS

module QuestionXMLSamples

  SINGLE = <<-eos
  <question>
      <statement text='What color is the sky (from earth)'/>
      <options type='single' hint='during daytime' randomize='true'/>
      <choices>
         <choice text='Blue' score='1' correct_text="That is correct! from the earth sky is in fact blue"/>
         <choice text='Black'     incorrect_text='Maybe from outerspace'/>
         <choice text='Red'       incorrect_text='On mars perhaps'/>
      </choices>
  </question>
  eos

  SINGLE_CHOICE_CORRECT_ANSWERS = 'Blue'
  QUESTION_COMMENT = { '_comment' => 'sky is blue' }

  MULTIPLE = <<-eos
  <question>
      <statement text='Which of the following animals are mammals'/>
      <options type='multiple' hint="mammals don't lay eggs" randomize='true'/>
      <choices>
         <choice text='Koala Bears' score='1' correct_text="Koala's and bears, in general, are mammals"/>
         <choice text='Chicken'    incorrect_text='Chicken lay eggs... not mammals'/>
         <choice text='Dogs'    score='1' correct_text="Dogs have large number of pups (5-10) called litters"/>
         <choice text='Snakes'  incorrect_text='Snakes lay eggs'/>
         <choice text='Crabs'  incorrect_text='Crab lay large number of eggs'/>
      </choices>
  </question>
  eos
  MULTIPLE_CHOICE_CORRECT_ANSWERS = ['Koala Bears', 'Dogs']  # Chicken, Snakes and Crabs are incorrect

  TRUEFALSE = <<-eos
  <question>
      <statement text='Which of the following statements are true or false'/>
      <options type='truefalse' hint="true the truth" randomize='true'/>
      <choices>
         <choice text='Sky is blue'         answer='true'     incorrect_text="Koala's and bears, in general, are mammals"/>
         <choice text='Chicken are mammals' answer='false'    incorrect_text='Chicken lay eggs... not mammals' comment='true' comment-name='evidence' comment-min-words='7' />
         <choice text='Wag tails the Dog'   answer='false'    incorrect_text="Dogs have large number of pups (5-10) called litters"/>
         <choice text='Snakes have legs'    answer='false'    incorrect_text='Snakes lay eggs'/>
         <choice text='Pigs can swim'       answer='true'     incorrect_text='Crab lay large number of eggs'/>
      </choices>
  </question>
  eos

  TRUEFALSE_CORRECT_ANSWERS = { "Sky is blue"         => "true",
                                "Chicken are mammals" =>"false",
                                "Wag tails the Dog"   =>"false",
                                "Snakes have legs"    =>"false",
                                "Pigs can swim"       =>"true"}

  TRUEFALSE_ANSWER_COMMENTS = { "Chicken are mammals" =>"Chicken lay egg egg egg egg egg egg egg" }

  MATCH = <<-eos
  <question>
      <statement text='Match the following animal into their categories'/>
      <options type='match' hint="sorting is to line thing up" randomize='true'/>
      <choices>
         <choice text='Koalas are' 
                  match='type of bears'    
                  correct_text="that is correct, koalas are bears" 
                  incorrect_text="Koala's are bears"/>
         <choice text='Chickens are'   
                  match='not mammals' 
                  correct_text="Chicken are in fact not mammals" 
                  incorrect_text='Chicken lay eggs... not mammals'
                  comment='true' comment-min-words='7' comment-name='evidence' />
         <choice text='Dogs are'      
                  match='canines'   
                  correct_text="Correct, dogs are referred to as canines"         
                  incorrect_text="Dogs are canines"
                  comment='true' comment-name='evidence' />
         <choice text='Snakes are'    
                  match='reptiles'
                  correct_text="good, snakes are reptiles" 
                  incorrect_text='Snakes are reptiles'/>
         <choice text='Crabs are'     
                  match='underwater foragers'
                  correct_text="Correct, crabs are roaches of the sea"    
                  incorrect_text='Crabs are bottom feeders'/>
      </choices>
  </question>
  eos

  MATCH_CORRECT_ANSWERS = { "Koalas are"    => "type of bears",
                            "Chickens are"  => "not mammals",
                            "Dogs are"      => "canines",
                            "Snakes are"    => "reptiles",
                            "Crabs are"     => "underwater foragers"}
                            
  ########################################################################
  #
  #                         UNGRADED QUESTIONS
  #
  #########################################################################
  # Essay type questions can have a name to store the response in the database.  If name is not provided than the statment is used to store the response.  It serves as a name space for multiple essays related to the same question.  the format of question in db should be internal_identifier[statement_text] = "answer"
  # title is used to store and lookup responses
  ESSAY = <<-eos
  <question>
    <statement text='how do you feel about the picture above'/>
    <options type='essay' min_words='20'/>
  </question>
  eos
  
  GRIDFORM = <<-eos
    <question>
      <statement text='What cities have you lived in?'/>
      <options type='gridform' />
      <items>
        <item type='checkbox' text='Lived in this city for more than one year' />
        <item type='checkbox' text='Attended school in this city' />
        <item type='number' text='How many minutes away was your school' />
      </items>
    </question>
  eos
  
  #### GUESS QUESTION TYPE
  # This question type is not scored but the user is given feedback about their guesses
  # SLIDER FEEDBACK: Guess responses of slider and number are evaluated against correct answers.  
  # Feedback for guesses is in three categories, "very good", "not bad" and "way off".  
  # In the example below, a guess within plus/minus 7.5% of the correct answer (i.e. a 15% range around the correct answer) is considered "very good". 
  # "not bad" is 30% range around the answer, i.e. plus minus 15%.  Anything larger than that is considered "way off". 
  # These ranges can be customized in question options
  # Example 1: Slider is 0-100, right answer is 25, and the guess is 39.  the 15% range around the right answer is 25-7.5 = 17.5 and 25+7 =33.
  #  The given answer is larger than the upper range.  Lets test if it is "not bad", i.e. 30% range.  
  #  This would be 25-15=10 and 25+15=40. We are within the "not bad" range so that is the feedback user will get.  
  # If instead of 0-100, the slider range is 0-20 or some other low/high number, and the right answer is 12 and the guess is 5 
  # then we apply same logic as above by normalizing the range to 0-100.  
  # The rnages in options assume a normalized range of 0-100 regardless of what the slider range is selected to be
  
  # NUMBER FEEDBACK: If the guess is smaller than or equal to 1.15x the right answer then its "very good", if its greater than 1.15x but smaller than 1.3x then its "not bad", any larger than 1.3x is "way off"
  GUESS =<<-eos
  <question>
    <statement text='Guess the following items'/>
    <options type='guess'>
      <range difference='15%' text='Very good guess' />
      <range difference='30%' text='Not bad, your guess is close' />
      <range default='true' text='No, not quite...' />
    </options>
    <item type='slider' min='0' max='100' text='% of students studying engineering in the US' answer='5'/>
    <item type='text' min_words='3' text='Oldest university in the world' answer='University of bologna'/>
    <item type='number' text='Number of letters in the longest english word' answer='45' /> 
  </question>
  eos
  

  SURVEY = <<-eos
  <question>
    <statement text='What animals do you like to have as pets'/>

    <options type='survey' />
    <item type="single_choice" text="Your gender">
      <option value='Male'/>
      <option value='Female'/>
    </item>

    <item type="multi_choice" text="Your favourite fruit(s)">
      <option value='Apples'/>
      <option value='Bananas'/>
      <option value='Grapes'/>
      <option value='Oranges'/>
    </item>

    <item type="date" text="Your date of birth"/>

    <item type="number" text="Your weight"/>

    <item type="text" text="Your first name"/>

    <item type="textarea" text="Your feedback"/>

    <item type="dropdown" text="Which state do you live in">
      <option value='New York'/>
      <option value='California'/>
      <option value='Flordia'/>
    </item>
  </question>
  eos
  
end

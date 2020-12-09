require 'rails_helper'
require 'webdrivers'

RSpec.feature "NewQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "create a new question", js: true do
    before (:each) do
      admin = FactoryBot.create(:admin)
      sign_in admin
      @c = FactoryBot.create(:course)
    end

    it "should fail if qname isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      click_on "Create question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/qname can't be blank/i)
    end

    it "should fail for multichoice question if qcontent isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "A new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Create question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/No question created: Qcontent missing newline-separated options for multichoice question/i)
    end

    it "should succeed if qname is included for numeric response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "NumericQuestion", from: "question_type"
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end

    it "should succeed if qname and image are included for free response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "FreeResponseQuestion", from: "question_type"
      attach_file('Image', 'testimg.png')
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end

    it "should succeed if both qname and qcontent are included for multichoice" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      click_on "Add an option"
      all('input[class="option_input"]')[0].set("a")
      click_on "Add an option"
      all('input[class="option_input"]')[1].set("b")
      click_on "Add an option"
      all('input[class="option_input"]')[2].set("b")
      click_on "Save current options"
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end
  end
end

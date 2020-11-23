require 'rails_helper' 
RSpec.feature "DestroyQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers
  describe "Destroy questions", js: true do
      it "should successfully destroy" do
        admin = FactoryBot.create(:admin)
        sign_in admin
        c = FactoryBot.create(:course)
        # Flakes due to dependency issues with Selenium webdriver
        visit course_questions_path(c)
        click_link "Create a new question"
        fill_in "question_qname", :with => "TEST"
        click_button "Add an option"
        fill_in "question_option", :with => "a"
        click_button "Save current options"
        fill_in "question_answer", :with => "a"
        click_button "Create question"
        expect(page.current_path).to eq(course_questions_path(c))
        expect(page.text).to match(/TEST/)
        click_link "destroy_TEST"
        expect(page.current_path).to eq(course_questions_path(c))
        expect(page.text).to match(/TEST destroyed/)
      end
  end
end

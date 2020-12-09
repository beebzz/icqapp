require 'rails_helper' 
require 'webdrivers'

RSpec.feature "DestroyQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers
  describe "Destroy questions", js: true do
      it "should successfully destroy" do
        admin = FactoryBot.create(:admin)
        sign_in admin
        c = FactoryBot.create(:course)
        visit course_questions_path(c)
        click_on "Create a new question"
        fill_in "question_qname", :with => "TEST"
        click_on "Add an option"
        find("input[class$='option_input']").set("a")
        click_on "Save current options"
        click_on "Create question"
        expect(page.current_path).to eq(course_questions_path(c))
        expect(page.text).to match(/TEST/)
        click_link "destroy_TEST"
        expect(page.current_path).to eq(course_questions_path(c))
        expect(page.text).to match(/TEST destroyed/)
      end
  end
end

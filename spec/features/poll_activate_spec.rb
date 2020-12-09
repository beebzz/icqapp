require 'rails_helper'
require 'webdrivers'

RSpec.feature "PollActivates", type: :feature do
  include Devise::Test::IntegrationHelpers
  
  describe "active poll visibility for student" do
    it "an active numeric poll should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Do a question"
      expect(page.text).to match(/Q1/)
      fill_in "response", :with => 1.0
      click_on "Submit answer"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq(1.0)
    end

    it "an active numeric poll should be notifiable" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      admin = FactoryBot.create(:admin)
      sign_in admin
      visit course_question_poll_path(c, q, p)
      expect(page.text).to match(/Q1/)
      #assert_emails 1 do
        click_on "Notify"
      #end
    end

    it "an active free response should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:free_response_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Do a question"
      expect(page.text).to match(/Q1/)
      fill_in "response", :with => "some text"
      click_on "Submit answer"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("some text")
    end

    it "an active multiple choice question should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :qcontent => %w{one two three four}, :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Do a question"
      expect(page.text).to match(/Q1/)
      choose "response_two"
      click_on "Submit answer"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("two")
    end

    it "update an multiple choice question with another response" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :qcontent => %w{one two three four}, :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Do a question"
      expect(page.text).to match(/Q1/)
      choose "response_two"
      click_on "Submit answer"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("two")

      choose "response_four"
      click_on "Submit answer"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("four")
    end
    
    it "an active multiple selection question should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:multi_sel_question, :qname => "Q1", :qcontent => %w{one two three four}, :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/Q1/)
      choose "response_two"
      choose "response_four"
      click_on "Select one(s) that best answers this question"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("two")
      expect(PollResponse.find(1).response).to eq("four")
    end
    
    it "an active attendance poll should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build( :attendance_question, :qname => "Attendance Poll", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Take attendance"
      expect(page.text).to match(/Attendance Poll/)
      expect(page).to have_button("Check in now")
    end
   
    it "the attendance check in button should be disabled after student response and verification text should appear" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build( :attendance_question, :qname => "Attendance Poll", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save
      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Take attendance"
      click_on "Check in now"
     
      expect(page).to have_button('Checked in successfully', disabled: true)
    end

    it "no poll should be visible if none are active" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      click_on "Do a question"
      expect(page.text).to match(/no question/i)
    end      
  end
end

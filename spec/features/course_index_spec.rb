require 'rails_helper'

RSpec.feature "CourseIndices", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "course index page" do
    it "should list courses that exist" do
      s = FactoryBot.create(:student)
      sign_in s
      c1 = Course.create!(:name => "One", :daytime => "TR 8:30-9:55")
      c2 = Course.create!(:name => "Two", :daytime => "MWF 10:20-11:10")
      c1.students << s
      c2.students << s

      visit courses_path
      expect(page.text).to match(/student\d+@colgate.edu/)
      expect(page.text).to match(/One.+TR 8:30-9:55/)
      expect(page.text).to match(/Two.+MWF 10:20-11:10/)
    end

    it "should not allow student to visit course show page for courses not enrolled in" do
      sign_in FactoryBot.create(:student)
      c1 = Course.create!(:name => "One", :daytime => "TR 8:30-9:55")
      c2 = Course.create!(:name => "Two", :daytime => "MWF 10:20-11:10")

      visit course_path(c1)
      expect(page.current_path).to eq(courses_path)
      expect(page.text).to match(/not enrolled/)
    end

    it "should allow a student enrolled in a course to visit the show page" do
      u = FactoryBot.create(:student)
      sign_in u
      c1 = Course.create!(:name => "One", :daytime => "TR 8:30-9:55")
      c2 = Course.create!(:name => "Two", :daytime => "MWF 10:20-11:10")
      u.courses << c1
      u.courses << c2

      visit course_path(c1)
      expect(page.current_path).to eq(course_path(c1))
      expect(page.text).to match(/no question/i)

      visit course_path(c2)
      expect(page.current_path).to eq(course_path(c2))
      expect(page.text).to match(/no question/i)

      allow(Time).to receive(:now) { Time.new(2019, 5, 15, 9, 0, 0, "-05:00") }
      visit course_path(10000)
      expect(page.current_path).to eq(courses_path)

      allow(Time).to receive(:now) { Time.new(2019, 5, 15, 10, 52, 0, "-05:00") }
      visit course_path(10000)
      expect(page.current_path).to eq(course_path(c2))
    end

    it "should allow an admin to see course details" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question)
      c.questions << q
      q.save
      visit course_path(c)
      expect(page.text).to match(/students enrolled/i)
    end
    
    it "should allow an admin to see attendance report" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:attendance_question)
      c.questions << q
      q.save
      visit attendance_report_path(c.id)
      expect(page.text).to match(/Attendance report/)
      #expect(page).to have_button("Cold call")
    end
    
    it "should allow an admin to cold call students" do
      s = FactoryBot.create(:student)
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      c.students << s
      visit attendance_report_path(c.id)
      expect(page).to have_button("Cold call")
      click_on("Cold call")
      expect(page.text).to match(/student\d+@colgate.edu/)
    end
  end
end
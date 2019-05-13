require 'rails_helper'

RSpec.describe Poll, type: :model do
  describe "multi choice poll options" do
    it "should return the question options with Poll#options" do
      c = Course.create(:name => "test", :daytime => "TR 9:55-10:10")
      opts= %w{opt1 opt2 opt3}
      q = MultiChoiceQuestion.create(:qname => "question", :course=>c, :qcontent => opts)
      q.save
      poll = q.new_poll
      expect(poll.options).to eq(opts)
    end

    it "#new_poll should return the right poll object" do
      c = Course.create(:name => "test", :daytime => "TR 9:55-10:10")
      q = FreeResponseQuestion.create(:qname => "question", :course => c)
      q.save
      poll = q.new_poll
      expect(poll.type).to eq("FreeResponsePoll")

      q = NumericQuestion.create(:qname => "question", :course => c)
      q.save
      poll = q.new_poll
      expect(poll.type).to eq("NumericPoll")
    end
  end

  describe "Poll#closeall" do
    it "should close all polls for a given course" do
      c = FactoryBot.create(:course_with_students)    
      1.upto(2) do |j|
        q = FactoryBot.build(:multi_choice_question, :qname => "question #{j}")
        c.questions << q
        1.upto(3) do |i|
          p = q.new_poll(:isopen => true, :round => i)
          p.save
        end
        q.save
      end
      Poll.closeall(c)
      Poll.all.each do |p|
        expect(p.isopen).to eq(false)
      end
    end

    it "should not close polls for other courses" do
      c1 = FactoryBot.create(:course_with_students, :name => "test course", :daytime => "MWF 9:20-10:10")
      c2 = FactoryBot.create(:course_with_students)    
      courses = [c1, c2]
      polls = Hash.new { Array.new }
      0.upto(1) do |x|
        0.upto(1) do |j|
          q = FactoryBot.build(:multi_choice_question, :qname => "question #{j}")
          courses[x].questions << q
          0.upto(2) do |i|
            p = q.new_poll(:isopen => true, :round => i)
            p.save
            polls[x] = polls[x] << p
          end
          q.save
        end
      end
      Poll.closeall(c1)
      
      polls[0].each do |p|
        expect(Poll.find(p.id).isopen).to be false
      end
      polls[1].each do |p|
        expect(Poll.find(p.id).isopen).to be true
      end
    end
  end
end

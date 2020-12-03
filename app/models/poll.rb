class Poll < ApplicationRecord
  belongs_to :question
  has_many :poll_responses, :dependent => :destroy
  has_many :users, :through => :poll_responses

  validates_associated :question

  def self.closeall(course)
    Poll.joins(:question).where("polls.isopen = ? AND polls.question_id = questions.id AND questions.course_id = ?", true, course.id).update_all(:isopen => false)
  end
end

class MultiChoicePoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "MultiChoicePollResponse", :poll => self, **h)
  end

  def options
    self.question.qcontent
  end

  def responses
    outhash = {}
    h = self.poll_responses.group(:response).count
    opts = self.question.qcontent
    0.upto(opts.length-1) do |i|
      outhash[opts[i]] = h[opts[i]].to_i
    end
    outhash
  end
end

class MultiSelPoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "MultiSelPollResponse", :poll => self, **h)
  end

  def options
    self.question.qcontent
  end

  def responses
    outhash = {}
    h = self.poll_responses.group(:response).count
    opts = self.question.qcontent
    0.upto(opts.length-1) do |i|
      outhash[opts[i]] = h[opts[i]].to_i
    end
    outhash
  end
end
    

class FreeResponsePoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "FreeResponsePollResponse", :poll => self, **h)
  end

  def responses
    self.poll_responses.group(:response).count
  end
end

class NumericPoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "NumericPollResponse", :poll => self, **h)
  end

  def responses
    h = Hash.new(0)
    self.poll_responses.select(:response).each { |r| h[r.response] += 1 }
    h
  end
end

class AttendancePoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "AttendancePollResponse", :poll => self, **h)
  end

  def responses
    self.poll_responses.group(:response).count
  end
end

class PollResponse < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  validates_associated :user
end

class MultiChoicePollResponse < PollResponse
end

class MultiSelPollResponse < PollResponse
end

class FreeResponsePollResponse < PollResponse
end

class NumericPollResponse < PollResponse
  def response
    read_attribute(:response).to_f
  end
end

class AttendancePollResponse < PollResponse
end

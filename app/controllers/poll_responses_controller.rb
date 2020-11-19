class PollResponsesController < ApplicationController
  def create
    @course = Course.find(params[:course_id])

    if !@course.students.include? current_user
      flash[:alert] = "You aren't enrolled in #{@course.name}.  If that is a mistake, please contact the administrator."
      redirect_to courses_path and return
    end

    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:poll_id])

    if !@poll.isopen
      flash[:alert] = "Poll is not open"
      redirect_to course_path(@course) and return
    end
    
    
    r = @poll.poll_responses.where(:user => current_user).first
    if !r
      r = @poll.new_response(:user => current_user)
    end
    r.response = params[:response]
    if r.save
      flash[:notice] = "Response recorded"
    else
      flash[:notice] = "Saving response failed"
    end
  
    respond_to do |format|
      format.js
      format.json { render :message => "Response recorded" }
      format.html { render course_path(@course) and return }
    end
    
  end
end

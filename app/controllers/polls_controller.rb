class PollsController < ApplicationController
  before_action :redirect_if_student

  def index
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @polls = @question.polls
  end

  def show
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])

    if request.xhr?
        render json: { responses: @poll.responses, type: @poll.type, answer: @poll.question.answer } and return
    end
  end

  def notify
    poll = Poll.find(params[:id])
    PollNotifyMailer.with(user: current_user, poll: poll).notify_email.deliver_now
    if request.xhr?
      render :json => { :done => true }
      return
    else 
      redirect_to courses_path and return
    end
  end

  def status
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    if !request.xhr?
        redirect_to course_question_poll_path(@course, @question, @poll) and return
    end

    p = @course.active_poll     
    q = @course.active_question
    status_path = "/courses/#{@course.id}/questions/#{q ? q.id : 0}/polls/#{p ? p.id : 0}/status";

    status = if p.nil?
      status_path = "/courses/#{@course.id}"
      'closed'
    elsif p && @poll && p.id == @poll.id
      'open'
    end
    render json: {'status': status, 'path': status_path }
  end

  def create
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    Poll.closeall(@course)
    num = @question.polls.maximum(:round).to_i
    @poll = @question.new_poll
    @poll.isopen = true
    @poll.round = num + 1
    if @poll.save
      flash[:notice] = "Poll started for #{@question.qname}"
      redirect_to course_question_poll_path(@course, @question, @poll)
    else
      flash[:warning] = "Failed to start poll for #{@question.qname}"
      redirect_to course_questions_path(@course)
    end
  end

  def update
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    @poll.update(:isopen => false)
    flash[:notice] = "Poll stopped for #{@question.qname}"
    redirect_to course_question_poll_path(@course, @question, @poll)
  end

  def destroy
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    @poll.destroy
    flash[:notice] = "Poll #{@poll.round} for #{@question.qname} destroyed"
    redirect_to course_question_polls_path(@course, @question)
  end
end

class StaticPagesController < ApplicationController
  def home
  	@title = "Home"
  end

  def about
  	@title = "About"
  end

  def contact
  end

  def api
  	@tilte = "API"
  end
  def mmls
    student = Student::Login.new
    @msg = student.login(params[:id],params[:mmlsPass],params[:camsysPass])
  end
end

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
    studentM = Student::Mmls.new(params[:id],params[:mmlsPass])
    studentC = Student::Camsys.new(params[:id],params[:mmlsPass])
    @jsonMmlsR = studentM.login_mmls
    @jsonMmlsArray = JSON.parse @jsonMmlsR.to_json
    @jsonCamsysR = studentC.login_camsys_v2
    @jsonCamsysArray = JSON.parse @jsonCamsysR.to_json
    if (@jsonMmlsArray["json"]["message"] == "Successful Login")
      @msg ="LogIN!"
    else
      @msg ="shit"
    end

  end
end

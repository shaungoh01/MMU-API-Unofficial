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
end

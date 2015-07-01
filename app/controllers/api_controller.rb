class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def update_bulletin
    agent = Mechanize.new
    agent.keep_alive = true
    agent.agent.http.retry_change_requests = true
    page = agent.get("https://online.mmu.edu.my/index.php")
    form = page.form
    bulletins = []
    form.form_loginUsername = ENV['STUDENT_ID']
    form.form_loginPassword = ENV['PORTAL_PASSWORD']
    page = agent.submit(form)
    page = agent.get("https://online.mmu.edu.my/bulletin.php")
    bulletin_number = 1
    while !page.parser.xpath("//*[@id='tabs-1']/div[#{bulletin_number}]").empty? and bulletin_number <= 20
      url = page.parser.xpath("//*[@id='tabs-1']/div[#{bulletin_number}]/p/a/@href").text
      unless (Bulletin.find_by_url(url))
        print "EXECUTING " + bulletin_number.to_s + "\n"
        bulletin_post = page.parser.xpath("//*[@id='tabs-1']/div[#{bulletin_number}]")
        bulletin = Bulletin.new
        bulletin.title = bulletin_post.xpath("p/a[1]").text
        bulletin_details = bulletin_post.xpath("div/div/text()").text.split("\r\n        ").delete_if(&:empty?)
        bulletin.posted_on = Time.parse(bulletin_details[0].split(" ")[2..5].join(" "))
        bulletin.url = page.parser.xpath("//*[@id='tabs-1']/div[#{bulletin_number}]/p/a/@href").text
        bulletin.expired_on = Time.parse(bulletin_details[1].split(" : ")[1])
        bulletin.author = bulletin_details[2].split(" : ")[1].delete("\t")
        bulletin.contents = bulletin_post.xpath("div/div/div").text.delete("\t").delete("\r")
        bulletin.save
      end
      bulletin_number = bulletin_number + 1
    end
    render json: JSON.pretty_generate( Bulletin.order(posted_on: :desc,url: :desc).limit(20).as_json)
  end

  # def portal
  #   bulletins = []
  #   agent = Mechanize.new
  #   page = agent.get("https://online.mmu.edu.my/index.php")
  #   form = page.form
  #   # form.form_loginUsername = params[:student_id]
  #   #form.form_loginUsername =  ENV['STUDENT_ID']
  #   form.form_loginPassword = params[:password]
  #   #form.form_loginPassword = ENV['PORTAL_PASSWORD']
  #   page = agent.submit(form)
  #   tab_number = 1
  #   bulletin_number = 1
  #   while !page.parser.xpath("//*[@id='tabs']/div[#{tab_number}]/div[#{bulletin_number}]").empty?
  #     bulletin = Hash.new
  #     bulletin[:title] = page.parser.xpath("//*[@id='tabs']/div[#{tab_number}]/div[#{bulletin_number}]/p/a[1]").text
  #     bulletin_details = page.parser.xpath("//*[@id='tabs']/div[#{tab_number}]/div[#{bulletin_number}]/div/div/text()").text.split("\r\n        ").delete_if(&:empty?)
  #     #remember to add android autolink
  #     bulletin[:posted_date] = bulletin_details[0].split(" ")[2..5].join(" ")
  #     bulletin[:expired_date] = bulletin_details[1].split(" : ")[1]
  #     bulletin[:author] = bulletin_details[2].split(" : ")[1].delete("\t")
  #     page.parser.xpath("//*[@id='tabs']/div[1]/div[2]/div/div/div")
  #     bulletin[:contents] = page.parser.xpath("//*[@id='tabs']/div[#{tab_number}]/div[#{bulletin_number}]/div/div/div").text.delete("\t").delete("\r")
  #     bulletins << bulletin
  #     bulletin_number = bulletin_number + 1
  #   end
  #   render :json => JSON.pretty_generate(bulletins.as_json)
  # end

  def refresh_token
    student = Student::Mmls.new(params[:student_id] ,params[:password])
    jsonR = student.refresh_token
    render jsonR
  end

  def attendance
    student = Student::Camsys.new(params[:student_id] ,params[:password])
    hashR = student.attendance
    hashR.to_json
    render :json => JSON.pretty_generate(hashR)
  end

  def login_camsys_v2
    student = Student::Camsys.new(params[:student_id] ,params[:camsys_password])
    hashR = student.login_camsys_v2
    hashR.to_json
    render :json => JSON.pretty_generate(hashR)
  end

  def login_camsys
    student = Student::Camsys.new(params[:student_id] ,params[:camsys_password])
    hashR = student.login_camsys
    hashR.to_json
    render :json => JSON.pretty_generate(hashR)
  end

  def timetable
  	student = Student::Camsys.new(params[:student_id] ,params[:camsys_password])
    hashR = student.timetable
    hashR.to_json
    render :json => JSON.pretty_generate(hashR)
  end
  def login_mmls
    student = Student::Mmls.new(params[:student_id] ,params[:mmls_password])
    hashR = student.login_mmls
    hashR.to_json
    render :json => JSON.pretty_generate(hashR)
  end

  def bulletin
    headers['Access-Control-Allow-Origin'] = "*"
    if !params[:last_sync].blank?
      last_sync = Time.parse(params[:last_sync])
      render json: Bulletin.where( "posted_on >= ?", last_sync.to_date).order(posted_on: :desc, url: :desc).limit(20).as_json( methods: :posted_date,except: [:posted_on,:created_at, :updated_at, :expired_on, :id])
    else
      render json: Bulletin.order(posted_on: :desc,url: :desc).limit(20).as_json( methods: :posted_date, except: [:posted_on,:created_at, :updated_at, :expired_on, :id])
    end
  end

  def mmls_refresh_subject
    student = Student::Mmls.new
    jsonR = student.mmls_refresh_subject(params[:subject_url],params[:cookie],params[:last_sync])
    render jsonR
  end

  private
   def timetable_params
      timetable_params.allow("student_id", "password")
   end
end

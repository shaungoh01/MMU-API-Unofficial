class Student::Mmls
	def initialize(id = 0,pass = 0)
		@id = id
		@pass = pass
	end
  
  def refresh_token
    agent = Mechanize.new
    agent.keep_alive = true
    agent.agent.http.retry_change_requests = true
    page = agent.get("https://mmls.mmu.edu.my")
    form = page.form
    token = form._token
    form.stud_id = @id
    form.stud_pswrd = @password
    page = agent.submit(form)
    laravel_cookie = agent.cookie_jar.first.value
    return :json=> {token: form._token, cookie: laravel_cookie}
  end
  def login_mmls
    agent = Mechanize.new
    agent.keep_alive = true
    agent.agent.http.retry_change_requests = true
    page = agent.get("https://mmls.mmu.edu.my")
    print "Page acquired \n"
    form = page.form
    form.stud_id = @id
    form.stud_pswrd = @pass
    token = form._token
    page = agent.submit(form)
    details_array = page.parser.xpath('/html/body/div[1]/div[3]/div/div/div/div[2]/div[2]/div[2]').text.delete("\r\t()").split("\n")
    details = Hash.new
    details[:name] = details_array[1]
    details[:faculty] = details_array[3]
    subject_links = page.links_with(:text => /[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9] . [A-Z][A-Z]/)
    subjects = []
    subject_links.each do |link|
      subject = Hash.new
      subject[:uri] = link.href
      subject[:name] = link.text
      subjects << subject
    end

    laravel_cookie = agent.cookie_jar.first.value
    unless page.parser.xpath('//*[@id="alert"]').empty?
     return :json => {message: "Incorrect MMLS username or password", status: 400}, status:400
    else
      return :json => {message: "Successful Login", profile: details, cookie: laravel_cookie, subjects: subjects, token: token,status: 100}
    end
  end

  def mmls_refresh_subject(subject_url , cookie ,last_sync)
    url = subject_url
    name = "laravel_session"
    value = cookie
    if !last_sync.blank?
      last_sync = Time.parse(last_sync)
    end
    domain = "mmls.mmu.edu.my"
    cookie = Mechanize::Cookie.new :domain => domain, :name => name, :value => value, :path => '/', :expires => (Date.today + 1).to_s
    agent = Mechanize.new
    agent.cookie_jar.add(cookie)
    agent.redirect_ok = false
    agent.keep_alive = true
    agent.agent.http.retry_change_requests = true
    page = agent.get(url)
    if page.code != "302"
      print "Page acquired, processing .. + \n"
      original = page.parser.xpath('/html/body/div[1]/div[3]/div/div/div/div[1]')
      subject_name = page.parser.xpath("/html/body/div[1]/div[3]/div/div/div/div[1]/div[1]/h3/div").text.delete("\n\t")
      subject = Subject.new
      subject.name = subject_name
      week_number = 1
      while !page.parser.xpath("//*[@id='accordion']/div[#{week_number}]/div[1]/h3/a").empty? do
        week = subject.weeks.build
        week.title = page.parser.xpath("//*[@id='accordion']/div[#{week_number}]/div[1]/h3/a").text.delete("\r").delete("\n").delete("\t").split(" - ")[0]
        announcement_number = 1
        announcement_generic_path = page.parser.xpath("//*[@id='accordion']/div[#{week_number}]/div[2]/div/div/div[1]")
        while !announcement_generic_path.xpath("div[#{announcement_number}]/font").empty? do
          posted_date = announcement_generic_path.xpath("div[#{announcement_number}]/div[1]/i[1]").text.delete("\r").delete("\n").delete("\t").split("               ").last
          valid = false
          if(!last_sync.blank?)
            if(Time.parse(posted_date).to_date >= last_sync.to_date)
              valid = true
            end
          else
            valid = true
          end

          if(valid)
            announcement = week.announcements.build
            announcement.title = announcement_generic_path.xpath("div[#{announcement_number}]/font").inner_text.delete("\r").delete("\t")
            contents = announcement_generic_path.xpath("div[#{announcement_number}]").children[7..-1]
            sanitized_contents = Sanitize.clean(contents, :remove_contents => ['script', 'style'])
            announcement.contents = sanitized_contents.delete("\r\t")
            announcement.author = announcement_generic_path.xpath("div[#{announcement_number}]/div[1]/i[1]").text.delete("\r\n\t\t\t\t\t;").split("  ").first[3..-1]
            announcement.posted_date = posted_date

            if !announcement_generic_path.xpath("div[#{announcement_number}]").at('form').nil?
              print("FILES EXISTS !!!")
              form_nok = announcement_generic_path.xpath("div[#{announcement_number}]").at('form')
              form = Mechanize::Form.new form_nok, agent, page
              file_details_hash =  Hash[form.keys.zip(form.values)]
              file = announcement.subject_files.build
              file.file_name = file_details_hash["file_name"]
              file.token = file_details_hash["_token"]
              file.content_id = file_details_hash["content_id"]
              file.content_type = file_details_hash["content_type"]
              file.file_path = file_details_hash["file_path"]
            end
          end
          announcement_number = announcement_number + 1
        end
          week_number = week_number + 1
       end
       download_forms = page.forms_with(:action => 'https://mmls.mmu.edu.my/form-download-content').uniq{ |x| x.content_id }
       download_forms.each do |form|
         file_details_hash =  Hash[form.keys.zip(form.values)]
         file = subject.subject_files.build
         file.file_name = file_details_hash["file_name"]
         file.token = file_details_hash["_token"]
         file.content_id = file_details_hash["content_id"]
         file.content_type = file_details_hash["content_type"]
         file.file_path = file_details_hash["file_path"]
       end
       return :json => subject.as_json(
          :include => [{ :weeks => {
          :include => {:announcements => {:include => :subject_files} }}}, :subject_files])
     else
       return :json => {message: "Cookie Expired", status: 400}, status: 400
     end
  end

end
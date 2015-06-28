class Student::Camsys

	def initialize(id,pass)
		@id = id
		@pass = pass
	end

	def attendance
	    agent = Mechanize.new
	    agent.keep_alive = true
	    agent.agent.http.retry_change_requests = true
	    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    page = agent.get("https://cms.mmu.edu.my/psp/csprd/?&cmd=login&languageCd=ENG")
	    form = page.form
	    form.userid = params[:student_id]
	    form.pwd = params[:password]
	    page = agent.submit(form)
	    page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/N_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL?
	      PORTALPARAM_PTCNAV=HC_SSS_attendance_PERCENT_GBL&EOPP.SCNode=HRMS&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=
	      CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Self%20Service&EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&FolderPath=
	      PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HCCC_ACADEMIC_RECORDS.HC_SSS_attendance_PERCENT_GBL&IsFolder=
	      false&PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fN_SR_STUDENT_RECORDS.
	      _SR_SS_ATTEND_PCT.GBL&PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%
	      2fN_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL&PortalContentProvider=HRMS&PortalCRefLabel=attendance%
	      20Percentage%20by%20class&PortalRegistryName=EMPLOYEE&PortalServletURI=https%3a%2f%2fcms.mmu.edu.my
	      %2fpsp%2fcsprd%2f&PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&PortalHostNode=HRMS&NoCrumbs=yes
	      &PortalKeyStruct=yes")
	    subjects_attendance = []
	    attendance_table = page.parser.xpath('//*[@id="N_STN_ENRL_SSVW$scroll$0"]')
	    attendance_table_fields = attendance_table.xpath("tr[2]").text.split("\n").reject!(&:empty?)
	    current_row = 3
	    while(!attendance_table.xpath("tr[#{current_row}]").empty? ) do
	      subject_row = attendance_table.xpath("tr[#{current_row}]").text.split("\n").reject!(&:empty?)
	      subject_is_not_barred = attendance_table.xpath("tr[#{current_row}]/td[6]/div/input").attr('value').value == "Y"? "false" : "true"
	      subject_row.insert(5, subject_is_not_barred)
	      subjects_attendance << Hash[attendance_table_fields.zip(subject_row)]
	      current_row = current_row + 1
	    end
	    return :json => JSON.pretty_generate(subjects_attendance.as_json)
 	end

 	def login_camsys_v2
	    agent = Mechanize.new
	    agent.keep_alive = true
	    agent.agent.http.retry_change_requests = true
	    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    page = agent.get("https://cms.mmu.edu.my/psp/csprd/?&cmd=login&languageCd=ENG")
	    form = page.form
	    form.userid = @id
	    form.pwd = @pass
	    page = agent.submit(form)
	    if page.parser.xpath('//*[@id="login_error"]').empty?
	      response = {}
	      page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/N_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL?
	        PORTALPARAM_PTCNAV=HC_SSS_attendance_PERCENT_GBL&EOPP.SCNode=HRMS&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=
	        CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Self%20Service&EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&FolderPath=
	        PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HCCC_ACADEMIC_RECORDS.HC_SSS_attendance_PERCENT_GBL&IsFolder=
	        false&PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fN_SR_STUDENT_RECORDS.
	        _SR_SS_ATTEND_PCT.GBL&PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%
	        2fN_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL&PortalContentProvider=HRMS&PortalCRefLabel=attendance%
	        20Percentage%20by%20class&PortalRegistryName=EMPLOYEE&PortalServletURI=https%3a%2f%2fcms.mmu.edu.my
	        %2fpsp%2fcsprd%2f&PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&PortalHostNode=HRMS&NoCrumbs=yes
	        &PortalKeyStruct=yes")
	      subjects_attendance = []
	      attendance_table = page.parser.xpath('//*[@id="N_STN_ENRL_SSVW$scroll$0"]')
	      attendance_table_fields = attendance_table.xpath("tr[2]").text.split("\n").reject!(&:empty?)
	      current_row = 3
	      while(!attendance_table.xpath("tr[#{current_row}]").empty? ) do
	        subject_row = attendance_table.xpath("tr[#{current_row}]").text.split("\n").reject!(&:empty?)
	        subject_is_not_barred = attendance_table.xpath("tr[#{current_row}]/td[6]/div/input").attr('value').value == "Y"? "false" : "true"
	        subject_row.insert(5, subject_is_not_barred)
	        subjects_attendance << Hash[attendance_table_fields.zip(subject_row)]
	        current_row = current_row + 1
	      end
	      response[:subjects_attendance] = subjects_attendance
	      page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.N_SSF_ACNT_SUMMARY.GBL?
	        PORTALPARAM_PTCNAV=N_SSF_ACNT_SUMMARY_GBL&EOPP.SCNode=HRMS&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=
	        CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Campus%20Finances&EOPP.SCFName=HCCC_FINANCES&EOPP.SCSecondary=true
	        &EOPP.SCPTfname=HCCC_FINANCES&FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.
	        HCCC_FINANCES.N_SSF_ACNT_SUMMARY_GBL&IsFolder=false&
	        PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fSA_LEARNER_SERVICES.N_SSF_ACNT_SUMMARY.GBL&
	        PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fSA_LEARNER_SERVICES.N_SSF_ACNT_SUMMARY.GBL&
	        PortalContentProvider=HRMS&PortalCRefLabel=Account%20Enquiry&PortalRegistryName=EMPLOYEE&
	        PortalServletURI=https%3a%2f%2fcms.mmu.edu.my%2fpsp%2fcsprd%2f&PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&
	        PortalHostNode=HRMS&NoCrumbs=yes&PortalKeyStruct=yes")
	      # if(!page.parser.xpath('//*[@id="SSF_SS_DERIVED_SSF_AMOUNT_TOTAL2"]').blank?)
	      #   amount_due = page.parser.xpath('//*[@id="SSF_SS_DERIVED_SSF_AMOUNT_TOTAL2"]').text
	      if(!page.parser.xpath('//*[@id="N_CUST_SS_DRVD_ACCOUNT_BALANCE"]').blank?)
	        amount_due = page.parser.xpath('//*[@id="N_CUST_SS_DRVD_ACCOUNT_BALANCE"]').text
	        response[:amount_due] = amount_due
	      end
	      page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/N_MANAGE_EXAMS.N_SS_EXAM_TIMETBL.GBL?
	        PORTALPARAM_PTCNAV=N_SS_EXAM_TIMETBL_GBL&EOPP.SCNode=HRMS&EOPP.SCPortal=EMPLOYEE&EOPP.SCName
	        =CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Self%20Service&EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&
	        FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.N_SS_EXAM_TIMETBL_GBL&IsFolder=false&
	        PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fN_MANAGE_EXAMS.
	        N_SS_EXAM_TIMETBL.GBL&PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%
	        2fc%2fN_MANAGE_EXAMS.N_SS_EXAM_TIMETBL.GBL&PortalContentProvider=HRMS&PortalCRefLabel=My%20Exam%
	        20Timetable&PortalRegistryName=EMPLOYEE&PortalServletURI=https%3a%2f%2fcms.mmu.edu.my%2fpsp%2fcsprd%
	        2f&PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&PortalHostNode=HRMS&NoCrumbs=yes&
	        PortalKeyStruct=yes")
	      exam_table = page.parser.xpath('//*[@id="N_SS_EXAM_TTBL$scroll$0"]/tr[2]/td/table')
	      exam_table_fields = exam_table.xpath('tr[1]').text.split("\n").reject!(&:blank?)
	      exam_timetable = []
	      current_row = 2
	      while(!exam_table.xpath("tr[#{current_row}]").empty? ) do
	        exam_row = exam_table.xpath("tr[#{current_row}]").text.split("\n").reject!(&:blank?)[1..-1]
	        exam_timetable << Hash[exam_table_fields.zip(exam_row)]
	        current_row = current_row + 1
	      end
	      response[:exam_timetable] = exam_timetable

	      agent.get("https://cms.mmu.edu.my/psp/csprd/EMPLOYEE/HRMS/?cmd=logout")

	      return :json=> JSON.pretty_generate(response.as_json)
	    else
	      return :json=> {error: "Incorrect CAMSYS username or password", status: 400}, status: 400
	    end
  	end

  	def login_camsys
	    agent = Mechanize.new
	    agent.keep_alive = true
	    agent.agent.http.retry_change_requests = true
	    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    page = agent.get("https://cms.mmu.edu.my/psp/csprd/?&cmd=login&languageCd=ENG")
	    form = page.form
	    form.userid = params[:student_id]
	    form.pwd = params[:camsys_password]
	    page = agent.submit(form)
	    if page.parser.xpath('//*[@id="login_error"]').empty?
	      page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/N_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL?
	        PORTALPARAM_PTCNAV=HC_SSS_attendance_PERCENT_GBL&EOPP.SCNode=HRMS&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=
	        CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Self%20Service&EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&FolderPath=
	        PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HCCC_ACADEMIC_RECORDS.HC_SSS_attendance_PERCENT_GBL&IsFolder=
	        false&PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fN_SR_STUDENT_RECORDS.
	        _SR_SS_ATTEND_PCT.GBL&PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%
	        2fN_SR_STUDENT_RECORDS.N_SR_SS_ATTEND_PCT.GBL&PortalContentProvider=HRMS&PortalCRefLabel=attendance%
	        20Percentage%20by%20class&PortalRegistryName=EMPLOYEE&PortalServletURI=https%3a%2f%2fcms.mmu.edu.my
	        %2fpsp%2fcsprd%2f&PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&PortalHostNode=HRMS&NoCrumbs=yes
	        &PortalKeyStruct=yes")
	      subjects_attendance = []
	      attendance_table = page.parser.xpath('//*[@id="N_STN_ENRL_SSVW$scroll$0"]')
	      attendance_table_fields = attendance_table.xpath("tr[2]").text.split("\n").reject!(&:empty?)
	      current_row = 3
	      while(!attendance_table.xpath("tr[#{current_row}]").empty? ) do
	        subject_row = attendance_table.xpath("tr[#{current_row}]").text.split("\n").reject!(&:empty?)
	        subject_is_not_barred = attendance_table.xpath("tr[#{current_row}]/td[6]/div/input").attr('value').value == "Y"? "false" : "true"
	        subject_row.insert(5, subject_is_not_barred)
	        subjects_attendance << Hash[attendance_table_fields.zip(subject_row)]
	        current_row = current_row + 1
	      end
	      agent.get("https://cms.mmu.edu.my/psp/csprd/EMPLOYEE/HRMS/?cmd=logout")
	      return :json => JSON.pretty_generate(subjects_attendance.as_json)
	    else
	      return :json => {error: "Incorrect CAMSYS username or password", status: 400}, status: 400
	    end
  	end
  	
  	def timetable
	  	agent = Mechanize.new
	    agent.keep_alive = true
	    agent.agent.http.retry_change_requests = true
	    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    page = agent.get("https://cms.mmu.edu.my")
	    form = page.form
	    form.userid = @id
	    form.pwd = @pass
	    page = agent.submit(form)
	    subjects = []
	    if page.parser.xpath('//*[@id="login_error"]').empty?
	      page = agent.get("https://cms.mmu.edu.my/psc/csprd/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL?PORTALPARAM_PTCNAV=HC_SSR_SSENRL_LIST&amp;EOPP.SCNode=HRMS&amp;EOPP.SCPortal=EMPLOYEE&amp;EOPP.SCName=CO_EMPLOYEE_SELF_SERVICE&amp;EOPP.SCLabel=Self%20Service&amp;EOPP.SCPTfname=CO_EMPLOYEE_SELF_SERVICE&amp;FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.HCCC_ENROLLMENT.HC_SSR_SSENRL_LIST&amp;IsFolder=false&amp;PortalActualURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fSA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL&amp;PortalContentURL=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2fEMPLOYEE%2fHRMS%2fc%2fSA_LEARNER_SERVICES.SSR_SSENRL_LIST.GBL&amp;PortalContentProvider=HRMS&amp;PortalCRefLabel=My%20Class%20Schedule&amp;PortalRegistryName=EMPLOYEE&amp;PortalServletURI=https%3a%2f%2fcms.mmu.edu.my%2fpsp%2fcsprd%2f&amp;PortalURI=https%3a%2f%2fcms.mmu.edu.my%2fpsc%2fcsprd%2f&amp;PortalHostNode=HRMS&amp;NoCrumbs=yes&amp;PortalKeyStruct=yes")
	      table = page.parser.xpath('//*[@id="ACE_STDNT_ENRL_SSV2$0"]')
	      a = 2
	      while !table.xpath("tr[#{a}]").empty? do
	        filter = table.xpath("tr[#{a}]/td[2]/div/table")
	        subject = Subject.new
	        subject.name = filter.xpath('tr[1]').text
	        status_temp = filter.xpath("tr[2]/td[1]/table/tr[2]").text.split("\n")
	        status_temp.delete("")
	        subject.status = status_temp[4]
	        i = 2
	        subject_class = subject.subject_classes.build
	        holder = filter.xpath('tr[2]/td[1]/table/tr[3]/td/div/table')
	        while !holder.xpath("tr[#{i}]").empty? do
	          temp = holder.xpath("tr[#{i}]")
	          test = temp.xpath('td[1]').text.split("\n")
	          unless test.join.blank?
	             unless subject_class.class_number.nil?
	               subject_class = subject.subject_classes.build
	             end
	            subject_class.class_number = temp.xpath('td[1]').text.delete("\n")
	            subject_class.section = temp.xpath('td[2]').text.delete("\n")
	            subject_class.component = temp.xpath('td[3]').text.delete("\n")
	          end
	          timeslot = subject_class.timeslots.build
	          timeslot.day = temp.xpath('td[4]').text.delete("\n").split(" ")[0]
	          timeslot.start_time = temp.xpath('td[4]').text.delete("\n").slice!(3,999).split(" - ")[0]
	          timeslot.end_time = temp.xpath('td[4]').text.delete("\n").slice!(3,999).split(" - ")[1]
	          timeslot.venue = temp.xpath('td[5]').text.delete("\n")
	          i = i + 1
	        end
	        a = a + 2
	        subjects << subject
	      end
	      subjects_json = subjects.as_json( :include => { :subject_classes => {
	                                                       :include => {:timeslots => { :except => [:id, :subject_class_id] } },
	                                                        :except => [:id] } },
	                                                        :except => [:id, :subject_class_id])


	      return :json => JSON.pretty_generate(subjects_json)
	        # :include => { :subjects => {
	        #  :include => { :subject_classes => {
	        #   :include => :timeslots, :except => [:id]} }, :except => [:id,:subject_class_id] }},
	        #    :except => [:id]))
	    else
	      message = Hash.new
	      message[:error] = "Incorrect username or password"
	      message[:status] = "400"
	      return :json => message
	    end
	end
 end
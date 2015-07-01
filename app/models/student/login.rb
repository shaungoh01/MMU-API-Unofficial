class Student::Login
	
	def login(id,mmlsPass,camsysPass)
	studentM = Student::Mmls.new(id,mmlsPass)
    studentC = Student::Camsys.new(id,camsysPass)
    hashLM = studentM.login_mmls
    hashLC = studentC.login_camsys_v2
    	if (hashLM["message"] == "Successful Login") && (hashLC.key("subjects_attendance"))
    	  return "LogIN!"
    	else
    	  return "shit"
    	end
    end
end
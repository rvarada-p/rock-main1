public with sharing class StudentRetentionHelper {
    
    public integer totalNumberOfSuccess;
    public integer totalNumberOfFailure;
    
    public StudentRetentionHelper() {
    	
    }
    	
    public void StudentRetentionHelper(list<Student_Program__c> lstStudentProgram){
	    totalNumberOfSuccess = 0;
	    totalNumberOfFailure = 0;
	    list<Student_Program__c> lstStudentProgramForUpdate = new list<Student_Program__c>();
	    list<Student_Retention__c> lstStudentRetention = new list<Student_Retention__c>();
	    apexLogHandler.apexLog log;

	   try{
	
	      Date toDay = Date.today();
	
	      // Run this script ONLY once / month on the 25th of the month
	      Integer dayThisMonth = toDay.day();
	      system.debug('>> Today: day date:' + dayThisMonth );
	      system.debug('>> Test.isRunningTest():' + Test.isRunningTest() );
	      system.debug('>> Script Settings: ' + Script_Settings__c.getValues('Current Settings').CheckDateOnStudentRetention__c);
	       if ((dayThisMonth != 25) && !Test.isRunningTest() && Script_Settings__c.getValues('Current Settings').CheckDateOnStudentRetention__c && Script_Settings__c.getValues('Current Settings').CheckDateOnStudentRetention__c!=null) {
		        system.debug('>> STUDENT RETENTION - only allowed to run on 25th of every month');
		        return;
	      	} 
	      
	      	//Loop through all the student programs to track retention
	       for(Student_Program__c sProgram: lstStudentProgram) { 
	       		Student_Retention__c studentRetention = new Student_Retention__c();
	       		studentRetention.Student_Program__c = sProgram.Id;
	       		studentRetention.Active__c = sProgram.isStudentProgramActive__c;
	       		lstStudentRetention.add(studentRetention);
	       }

 	     if(!lstStudentRetention.isEmpty()){
	       
	        Database.Saveresult[] saveResult = Database.insert(lstStudentRetention,false);
	        for (Database.SaveResult sr : saveResult) {
	          if (sr.isSuccess()) {
	            totalNumberOfSuccess++;
	          } else {
	            // Operation failed, so get all errors                
	            totalNumberOfFailure++;
	          }                        
	        }
	        
	      }

	    }
	    catch(Exception exp) {
	    	
	    }
   }
}
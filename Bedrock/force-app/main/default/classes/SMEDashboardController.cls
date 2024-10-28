/************************************************************************
Name  : SMEDashboardController
Developer: Sarah Khalid, Jan 2017
Description: Apex controller for the SMEDashboard home page
*************************************************************************/

public with sharing class SMEDashboardController {
	
	public list<Id> competencyIds { get; set; }
	public Id loggedInSMEId { get; set; }
	public Date nextTermStart { get; set; }
	public map<Id, SMECompetencyCard> competencyCards { get; set; }
	
	//This is the constructor for the page and pulls up the SME assignment cards grouped by the competency code
	public SMEDashboardController() {
		try { 
			
			String dashboardErrorMessage = SME_Dashboard__c.getValues('Current Settings').Empty_Dashboard_Error_Message__c;
			loggedInSMEId = UserInfo.getUserId();
			
			//get the next term start date
			getNextStartDate();
			//list<Student_Competency__c> smeSCs = new list<Student_Competency__c>([SELECT Id, Student_Assigned__c, Competency__c, Competency_Title__c, Competency_Code__c, Engagement_Unmet__c, New_Self_Assessment__c, New_Messages__c, Engagement_Required__c, Outreach_Required__c FROM Student_Competency__c WHERE SME__c = :loggedInSMEId AND IsCompleted__c = false AND Pause_Competency__c = false AND IsStudentProgramActive__c = true]);
			list<Student_Competency__c> smeSCs = new list<Student_Competency__c>([SELECT Id, Student_Assigned__c, Competency__c, IsCompleted__c, Pause_Competency__c, Competency_Title__c, Competency_Code__c, Engagement_Unmet__c, New_Self_Assessment__c, New_Messages__c, Engagement_Required__c, Outreach_Required__c FROM Student_Competency__c WHERE SME__c = :loggedInSMEId AND Student_Program__r.IsStudentProgramActive__c = true]);
			system.debug('SCs ' + smeSCs);
			System.debug('Running as : ' + loggedInSMEId);
			if(smeSCs.size()== 0 && dashboardErrorMessage!=null) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, dashboardErrorMessage));
			}
			
			map<Id, list<Student_Competency__c>> mapSC = new map<Id, list<Student_Competency__c>>();
			//Loop through all the Student Competencies assigned to a SME which are not completed or paused
			for(Student_Competency__c sc : smeSCs) {
				if(mapSC.containsKey(sc.Competency__c)) {
					mapSC.get(sc.Competency__c).add(sc);	
				}
				else {
					mapSC.put(sc.Competency__c, new List <Student_Competency__c> { sc });
				}
			}
			
			competencyCards = new map<Id, SMECompetencyCard>();
			//Loop through all the Student Competencies grouped and count all the different numbers
	        for(String scId :  mapSC.keySet()) {
	        	SMECompetencyCard competencyCard = new SMECompetencyCard();
	        	competencyCard.competencyId = scId; 
	        	if(mapSC.containsKey(scId)) {
	        		List<Student_Competency__c> studentComps = mapSC.get(scId);
	        		System.debug('Student Comps for ' + scId + ' List of SCs :: ' + studentComps);
	        		for(Student_Competency__c sc : studentComps) {
	        			
		        		if(sc.Engagement_Unmet__c && sc.IsCompleted__c == false && sc.Pause_Competency__c == false) {
		        			competencyCard.unmetRequirements++;
		        		}
		        		if(sc.Student_Assigned__c && sc.IsCompleted__c == false && sc.Pause_Competency__c == false) {
		        			competencyCard.noAssignedStudents++;
		        		}
		        		if(sc.Outreach_Required__c && sc.IsCompleted__c == false && sc.Pause_Competency__c == false) {
		        			competencyCard.outreachRequired++;
		        		}
		        		if(sc.New_Self_Assessment__c && sc.IsCompleted__c == false && sc.Pause_Competency__c == false) { 
		        			competencyCard.pendingSelfAssessments++;
		        		}
		        		if(sc.New_Messages__c!=null && sc.IsCompleted__c == false && sc.Pause_Competency__c == false) {
		        			competencyCard.newMessages += Integer.valueOf(sc.New_Messages__c);
		        		}
		        		if(sc.New_Messages__c!=null && (sc.IsCompleted__c == true || sc.Pause_Competency__c == true)) {
		        			competencyCard.newMessagesArchived += Integer.valueOf(sc.New_Messages__c);
		        		}
		        		competencyCard.competencyCode = sc.Competency_Code__c;
		        		competencyCard.competencyTitle = sc.Competency_Title__c;
	        		}
	        		competencyCards.put(scId, competencyCard);
	        	} 
	        }	 
	    	System.debug('Competency Cards ::: ' + competencyCards); 		
		}
		catch(Exception exp) {
			
		}
		
	}
    
    
	//This method gets the next term start date
	public Date getNextStartDate() {
		Date todaysDate = System.today();
		try {
			List<Program_Start_Date__c> startDates = new List<Program_Start_Date__c>([SELECT Id, Start_Date__c FROM Program_Start_Date__c WHERE Start_Date__c > :todaysDate AND Display_on_web__c = true AND Accepting_New_Students__c = true ORDER BY Start_Date__c asc]);
			if(startDates!=null) {
				nextTermStart = startDates[0].Start_Date__c;
			}
		}
		catch(Exception exp) {
			
		}
		return nextTermStart;
	}	
	
	//Inner class for containing the variables for the Competency Card
	public class SMECompetencyCard {
		public Id competencyId { get; set; }
		public String competencyCode { get; set; }
		public String competencyTitle { get; set; }
		public Integer noAssignedStudents { get; set; }
		public Integer pendingSelfAssessments { get; set; }
		public Integer newMessages { get; set; }
		public Integer newMessagesArchived { get; set; }
		public Integer studentCheckIns { get; set; }
		public Integer unmetRequirements { get; set; }
		public Integer outreachRequired { get; set; }
		
		public SMECompetencyCard() {
			this.pendingSelfAssessments = 0;
			this.newMessages = 0;
			this.newMessagesArchived = 0;
			this.studentCheckIns = 0;
			this.unmetRequirements = 0;
			this.outreachRequired = 0;	
			this.noAssignedStudents = 0;	
		}
		
	}
    
}
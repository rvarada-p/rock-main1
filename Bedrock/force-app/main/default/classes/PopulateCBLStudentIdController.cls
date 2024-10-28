/*******************************************************************
Name  : PopulateCBLStudentIdController
Author: Vinod (Appirio)
Date  : December 09, 2014
Related Task: T-338463
Description: Controller class for the page PopulateCBLStudentId
*************************************************************************/
public with sharing class PopulateCBLStudentIdController {
	ID contactID;
	public PopulateCBLStudentIdController(ApexPages.StandardController controller){
		contactID = controller.getId();
	}
	public pageReference populateCBLStudentId(){	
		ContactHelper objHelper = new ContactHelper();
		set<ID> contactIDs = new set<ID>();
		contactIDs.add(contactID);
		objHelper.populateCBLStudentId(contactIDs);
		return new pageReference('/'+contactID); 
	}
}
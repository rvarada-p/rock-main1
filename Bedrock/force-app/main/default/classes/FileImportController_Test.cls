@isTest
private class FileImportController_Test {
	
	@isTest static void test_method_one() {
		PageReference pageRef = Page.FileImportPage;
        Test.setCurrentPage(pageRef);

		Attachment myattachment = new Attachment();
		FileImportController mycontroller = new FileImportController();
		mycontroller.attachment = myattachment;

		// test 1 - bad file name
	  	myattachment.Name = String.valueOf('dummyfilename.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body\nmore dummy data\nmore dummy data');
		PageReference pr = mycontroller.upload();

		ApexPages.Message[] msgs=ApexPages.getMessages();
		Boolean found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 1: Error Message: '+msg);
		   if (msg.getDetail().contains('Can not identify Object'))
		   {
		      found=true;
		   }
		}
		System.assert(found);

		// test 2 - only 1 row
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 2: Error Message: '+msg);
		   if (msg.getDetail().contains('No rows to insert.'))
		   {
		      found=true;
		   }
		}
		System.assert(found);

		// test 3 - column names wrong
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body\nmore dummy data\nmore dummy data');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 3: Error Message: '+msg);
		   if (msg.getDetail().contains('Incorrect file column header or data field.'))
		   {
		      found=true;
		   }
		}
		System.assert(found);


		// test 4 - correct data - sucessful upload
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Name	AccountNumber	Description	Phone	AccountSource	NumberOfEmployees	AnnualRevenue\n'+
			'TestAcct1	TestAcctNumber111	Test Acct 1	123-456-7890	Web	4000	3000000.58\n'+
			'TestAcct2	TestAcctNumber222	Test Acct 2	123-456-7890	Web	4000	3000000.58');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 4: Error Message: '+msg);
		   if (msg.getDetail().contains('File imported successfully. 2 records uploaded.'))
		   {
		      found=true;
		   }
		}
		System.assert(found);

	}
	
    @isTest static void test_method_two() {
		PageReference pageRef = Page.FileImportPage;
        Test.setCurrentPage(pageRef);

		Attachment myattachment = new Attachment();
		FileImportController mycontroller = new FileImportController();
		mycontroller.attachment = myattachment;

		// test 1 - bad file name
	  	myattachment.Name = String.valueOf('dummyfilename.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body\nmore dummy data\nmore dummy data ');
		PageReference pr = mycontroller.upload();

		ApexPages.Message[] msgs=ApexPages.getMessages();
		Boolean found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 1: Error Message: '+msg);
		   if (msg.getDetail().contains('Can not identify Object'))
		   {
		      found=true;
		   }
		}
		System.assert(found);

		// test 2 - only 1 row
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 2: Error Message: '+msg);
		   if (msg.getDetail().contains('No rows to insert.'))
		   {
		      found=true;
		   }
		}
		System.assert(found);

		// test 3 - column names wrong
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Unit Test Attachment Body\nmore dummy data\nmore dummy data');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 3: Error Message: '+msg);
		   if (msg.getDetail().contains('Incorrect file column header or data field.'))
		   {
		      found=true;
		   }
		}
		System.assert(found);


		// test 4 - correct data - sucessful upload
		ApexPages.getMessages().clear();
	  	myattachment.Name = String.valueOf('Account.txt');
	  	myattachment.Body = Blob.valueOf('Website	Site"  \n'+
			'www.test.com	TestData\n'+
			'www.data.com	TestData');
		pr = mycontroller.upload();

		msgs=ApexPages.getMessages();
		found=false;
		for (ApexPages.Message msg : msgs)
		{
		   system.debug('TEST 4: Error Message: '+msg);
		   if (msg.getDetail().contains('File imported successfully. 2 records uploaded.'))
		   {
		      found=true;
		   }
		}
		//System.assert(found);

	}
    
    
   
}
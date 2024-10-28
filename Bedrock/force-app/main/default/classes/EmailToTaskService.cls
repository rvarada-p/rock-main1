global class EmailToTaskService implements Messaging.InboundEmailHandler {
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
																Messaging.InboundEnvelope env) {
 
		// Create an InboundEmailResult object for returning the result of the
		// Apex Email Service
		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

		system.debug('>>> EmailToTaskService: Inbound Email Received ');
		system.debug('> email.result:'+result);
		system.debug('> email.fromAddress:' + email.fromAddress);
		system.debug('> env.fromAddress:' + env.fromAddress);
		system.debug('> email.toAddresses:' + email.toAddresses);
		system.debug('> env.toAddress:' + env.toAddress );
		system.debug('> email.subject:' + email.subject);
		system.debug('> email.htmlbody:' + email.htmlBody);
		//system.debug('email.plainTextBody:' + email.plainTextBody);

		String taskParentRecordID = '';

		// Looking for the 'EmailToTaskID' token in either the: header, subject, or email body
		// In subject or body, ID is preceded and terminated by a colon ':'
		// Example:    EmailToTaskID:a0G17000000CmBn:

		// First check header
		for (Messaging.InboundEmail.Header header : email.headers) {
			if (header != null) {
	    	if (header.name == 'EmailToTaskID')
	      		taskParentRecordID = header.value;
      }
		}

		// If not in header, check subject and then body
		if (taskParentRecordID == '') {
			if (email.subject.contains('EmailToTaskID:'))
			{
				List<String> parts = email.subject.split('EmailToTaskID:');
				List<String> parts2 = parts[1].split(':');
				taskParentRecordID = parts2[0];
			}
			else if (email.htmlBody.contains('EmailToTaskID:'))
			{
				List<String> parts = email.htmlBody.split('EmailToTaskID:');
				List<String> parts2 = parts[1].split(':');
				taskParentRecordID = parts2[0];
			}
		}

		system.debug('>>> taskParentRecordID: ' + taskParentRecordID );
		if (taskParentRecordID <> '')
		{
        Task newTask = new Task();
        newTask.Description = email.htmlBody.replaceAll('<[^>]+>','');
        newTask.Priority = 'Normal';
        newTask.Status = 'Completed';
        newTask.Subject = email.subject;
        newTask.WhatId = (Id) taskParentRecordID;
        newTask.OwnerId = UserInfo.getUserId();
        newTask.ActivityDate = System.today();

        try {
	        insert newTask;
		    }
				catch (System.DmlException e) {
					system.debug('ERROR: Failed to insert task record:' + e);

					// Most likely: a bad taskParentRecordID
					// Orphan email handling
					result.success = false;
					result.message = 'ERROR: Failed to insert task record';
					return result;
			}
		}
		else
		{
			system.debug('ERROR: No taskParentRecordID token found');
			// Orphan email handling

			result.success = false;
			result.message = 'ERROR: No taskParentRecordID token found';
			return result;
		}
		
		result.success = true;
		return result;
	}
}
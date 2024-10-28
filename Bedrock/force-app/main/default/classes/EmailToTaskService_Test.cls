@isTest
private class EmailToTaskService_Test {
	
	@isTest static void test_EmailToTaskService() {

		system.debug('>> EmailToTaskService_Test');

		EmailToTaskService ETTS = new EmailToTaskService();
		Messaging.InboundEmailResult IER;

		// Insert test Account
		Account testAcc = new Account(Name='Test Account');
		insert testAcc;
		Id testAccId = testAcc.Id;

    Messaging.InboundEmail emailInTest = new Messaging.InboundEmail() ;
    Messaging.InboundEnvelope envInTest = new Messaging.InboundEnvelope();

    emailInTest.subject = 'test subject';
    emailInTest.htmlbody = '<html>test html body</html>';

		emailInTest.headers = new List<Messaging.InboundEmail.Header>();
    Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
    header.name = 'test';
    header.value = 'test';
    emailInTest.headers.add(header);

    // Test 1: set no return tag
		IER = ETTS.handleInboundEmail(emailInTest, envInTest);
		system.debug('>> TEST 1: Success:'+IER.success+' Message:'+IER.message);
		system.assertEquals(IER.success, false);

    // Test 2: set body return tag
    emailInTest.htmlbody = '<html>test body EmailToTaskID:'+testAccId+':</html>';
		IER = ETTS.handleInboundEmail(emailInTest, envInTest);
		system.debug('>> TEST 2: Success:'+IER.success+' Message:'+IER.message);
		system.assertEquals(IER.success, true);

    // Test 3: set invalid body return tag
    emailInTest.htmlbody = '<html>test body EmailToTaskID:0011700000ABCDE:</html>';
		IER = ETTS.handleInboundEmail(emailInTest, envInTest);
		system.debug('>> TEST 3: Success:'+IER.success+' Message:'+IER.message);
		system.assertEquals(IER.success, false);

    // Test 4: set subject return tag
    emailInTest.subject = 'test subject EmailToTaskID:'+testAccId+':';
		IER = ETTS.handleInboundEmail(emailInTest, envInTest);
		system.debug('>> TEST 4: Success:'+IER.success+' Message:'+IER.message);
		system.assertEquals(IER.success, true);

    // Test 5: set return tag in header
    header.name = 'EmailToTaskID';
    header.value = (String) testAccId;
    emailInTest.headers.add(header);
		IER = ETTS.handleInboundEmail(emailInTest, envInTest);
		system.debug('>> TEST 5: Success:'+IER.success+' Message:'+IER.message);
		system.assertEquals(IER.success, true);

	}
	
}
/*
 * Test Class For PrivateChatterMessageController,ChatterMessageTrigerHandler and TriggeronChatterMessage trigger 
 */
@isTest
public class PrivateChatterMessageControllerTest {
  
    static String userId;

    static{
         User testUser1 = processTestUser('PvChtrDemoUser150422');
               insert testUser1;
        userId = testUser1.Id;

    }
    /*
    * Testmethod for different data processing functions
    */
    
    @IsTest(SeeAllData=true)
     static  void  testPrivateChatterMessage(){
        
            Test.startTest();
             
                 PrivateChatterMessageController testController = new PrivateChatterMessageController();            
                //Test Sending New Message
                String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Demo Message to user2 from user1',userId);

                system.assert(conversationId <> null);
                
                //messages of any conversation
                  testController.selectedConversationId = conversationId;
                  testController.processMessagesofConversation();
                  system.assert(testController.lisofMessagesofSpecificConversation <> null);   
                 //replyToMessage
                   conversationId = PrivateChatterMessageController.processReplyonMessage('Reply Message',testController.lastMessageId);
                  system.assert(conversationId <> null);
                  
                   testController.processReturntoMainPage();        
                  
                                                      
            Test.stopTest();
            
            
    } 
    
    @IsTest(SeeAllData=true)
    static  void testProcessAllConversationandMesseges(){
        Test.startTest();
               //autopopulate User Test
                
                
        List<PrivateChatterMessageController.UserDetails> listofSuggestedUsers = PrivateChatterMessageController.processListofUsersforAutoPopulate('PvChtrDemoUser150422');
                system.assert(listofSuggestedUsers.size()==1);
                 PrivateChatterMessageController testController = new PrivateChatterMessageController(); 
        
        String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Demo Message to user2 from user1',userid);
        system.assert(conversationId <> null);
                //List<ConnectApi.ChatterMessage> chatterMsg = new List<ConnectApi.ChatterMessage>();
                //chatterMsg.messages('Test');
                //messages of any conversation
                  testController.selectedConversationId = conversationId;
                 // testController.processMessagesofConversation();
            
               //Test all conversations
                //testController.processAllConversations();
                 //system.assert(testController.listofAllPrivateConversations <> null);
                testController.conversationSearchString = 'Demo*';
        
                testController.messageSearchString = 'Demo*';
                testController.processSearchMessagesofConversation();
                testController.processSearchConversations();

        
        Test.stopTest();          
    }
    
    @IsTest(SeeAllData=true)
    static  void testsearchAllConversationandMesseges(){
        Test.startTest();
               //autopopulate User Test      
        List<PrivateChatterMessageController.UserDetails> listofSuggestedUsers = PrivateChatterMessageController.processListofUsersforAutoPopulate('PvChtrDemoUser150422');
                system.assert(listofSuggestedUsers.size()==1);
                 PrivateChatterMessageController testController = new PrivateChatterMessageController(); 
        
        String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Demo Message to user2 from user1',userid);

        system.assert(conversationId <> null);
                testController.selectedConversationId = conversationId;
                testController.processMessagesofConversation();
                conversationId = PrivateChatterMessageController.processReplyonMessage('Reply Message',testController.lastMessageId);
                testController.conversationSearchString = 'test';
                testController.messageSearchString = 'from';
                ConnectApi.ChatterConversationSummary summary= ConnectApi.ChatterMessages.markConversationRead(conversationId, true);
               
                 testController.processSearchConversations();
             testController.processSearchMessagesofConversation();
               

        
        Test.stopTest();          
    }
    
     @IsTest(SeeAllData=true)
     static  void  testPrivateChatterMessage1(){
        
            Test.startTest();
             
                  List<PrivateChatterMessageController.UserDetails> listofSuggestedUsers = PrivateChatterMessageController.processListofUsersforAutoPopulate('PvChtrDemoUser150422');
                system.assert(listofSuggestedUsers.size()==1);
                 PrivateChatterMessageController testController = new PrivateChatterMessageController(); 
        
        String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Demo Message to user2 from user1',userid);

        system.assert(conversationId <> null);
                testController.selectedConversationId = null;
                testController.processMessagesofConversation();
                testController.conversationSearchString = null;
                testController.messageSearchString = null;
                ConnectApi.ChatterConversationSummary summary= ConnectApi.ChatterMessages.markConversationRead(conversationId, true);
               
                 testController.processSearchConversations();
             testController.processSearchMessagesofConversation();
                                                      
            Test.stopTest();
            
            
    }

    
    public static User processTestUser(String name){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='system administrator']; 
        User testUser  = new User(Alias = 'tst', 
                                  Email=name+'@sf1testorg.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName=name, 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = testProfile.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', 
                                  UserName=name+'@sf1testorg.com');
        return testUser;
    }


}
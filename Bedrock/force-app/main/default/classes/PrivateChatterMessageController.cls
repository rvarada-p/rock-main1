/*
*@Purpose : Controller for PrivateChatterMessage sf1 vf page
*/
public without sharing class PrivateChatterMessageController {
	
 public List<ConversationDetail>    		listofAllPrivateConversations				{get;set;}  //List of All Conversation.When Page loads we display list conversations
 public List<ConversationDetail>   		    lisofMessagesofSpecificConversation			{get;set;} 	//List of Messages of specific conversation.When clicked on any conversation we display all messages
 public boolean 							showAllMessages								{get;set;}	//Render the main conversation page
 public boolean 							showMessageList								{get;set;}	//Render messages of any specific conversation
 public String 								selectedConversationId						{get;set;}	//When user select any conversation then this property holds conversationId of that conversation.
 public String 								conversationMemberName						{get;set;}  //Conversation member name to display on top
 public String 								lastMessageId								{get;set;}  //This property hold messageId to use in reply functionality
 public String 								searchedRecordId							{get;set;}  //When any To : user is selected after autopopulate searching in New Message Modal .This property holds the userId
 public String 								conversationSearchString					{get;set;}  //Search String for all conversation
 public String 								messageSearchString							{get;set;}  //Search string of messages under specific conversation
 public String                      		statusMessage                               {get;set;}  //Status messages
                        
 
 /*
 *@ Constructor
 *@ purpose : When page loads we fetch all recent private conversations that current user has access.
 */
 public PrivateChatterMessageController(){	
 	processAllConversations();
 }	
	
 /*
 * @purpose  Whenever user wants to open it's conversations main page ,this function refresh the data.
 */ 
 public void processReturntoMainPage(){
 	    showAllMessages = false;
 		showMessageList = false;
 		selectedConversationId = null;
 	 	processAllConversations();
 	
 }
 
  /*
 * @purpose  Wrapper Class for Conversation users to hold user properties
 */ 
  public Class ConversationUser{
 	public String userId	{get;set;}
 	public String name		{get;set;}
 	public String imageUrl	{get;set;} 	
 }
 
 /*
 * @purpose  Wrapper Class for Conversation Detail to hold conversation properties
 */ 
 public Class ConversationDetail{
 	public string 				messageBody					{get;set;}
 	public String			    sentDate					{get;set;}
 	public String 				relatedConversationId		{get;set;}	
 	public ConversationUser 	userDetails					{get;set;}	
 	public String               cardColor                   {get;set;}
 }
 
 
 /*
 *@purpose  This function fetch all coversations that loggged in user has access.
 *@         When page loads is displays list of conversation and it also helps to identify which are unread.
 *@         ConnectApi getConversations() function is used to fetch conversation list.
 *@ Result : List of conversations
 */
 public void processAllConversations(){
 	statusMessage = null; 	
 	showAllMessages = true;
 	showMessageList = false;
 	try{
	    listofAllPrivateConversations = new List<ConversationDetail>();
	 	ConnectApi.ChatterConversationPage  page = ConnectApi.ChatterMessages.getConversations();
	 	for(ConnectApi.ChatterConversationSummary conversation : page.conversations){
		        ConversationDetail conversationdetail = new ConversationDetail();
		        	conversationdetail.messageBody = conversation.latestMessage.body.text;
		        	conversationdetail.relatedConversationId = conversation.latestMessage.conversationId;
		        	conversationdetail.sentDate =  conversation.latestMessage.sentDate.format();
		        	for(ConnectApi.UserSummary userSumary: conversation.members){
		        		if(userSumary.id <> userinfo.getUserId()){
		        			conversationdetail.userDetails = new ConversationUser();
		        			conversationdetail.userDetails.userId = userSumary.id;
		        			conversationdetail.userDetails.name = userSumary.name;
		        		}
		        	}
		            conversationdetail.userDetails.imageUrl = conversation.latestMessage.sender.photo.smallPhotoUrl;
		            conversationdetail.cardColor = label.SF1ReadColorCode;
		            if(!conversation.read){
		            	conversationdetail.cardColor = label.Sf1UnreadColorCode;
		            }
		        	
		        listofAllPrivateConversations.add(conversationdetail);
	     }
	     if(listofAllPrivateConversations.size()==0){
	 	 	statusMessage = LABEL.SF1NoRecordLabel;
	 	 }
 	 }catch(Exception e){
 	 	statusMessage = LABEL.SF1ErrorMessage;
 	 }
 }
 
  /*
 *@purpose  This function fetch all coversations that loggged in user has access based on search parameter
 *@         When User search by specific string input this function returns list of conversations that matches.
 *@         ConnectApi searchConversations(String searchInput) function is used to fetch searched conversation list.
 *@ Result : List of searched conversations
 */
 public void processSearchConversations(){
 	statusMessage = null;
 	showAllMessages = true;
 	showMessageList = false;
 	try{
 		listofAllPrivateConversations = new List<ConversationDetail>();
	 	if(conversationSearchString <> null && conversationSearchString.length() >1){
		 	ConnectApi.ChatterConversationPage  converSationpage = ConnectAPI.ChatterMessages.searchConversations(conversationSearchString);		 	
			for(ConnectApi.ChatterConversationSummary conversation : converSationpage.conversations){
		        ConversationDetail conversationdetail = new ConversationDetail();
		        	conversationdetail.messageBody = conversation.latestMessage.body.text;
		        	conversationdetail.relatedConversationId = conversation.latestMessage.conversationId;
		        	conversationdetail.sentDate =  conversation.latestMessage.sentDate.format();
		        	for(ConnectApi.UserSummary userSumary: conversation.members){
		        		if(userSumary.id <> userinfo.getUserId()){
		        			conversationdetail.userDetails = new ConversationUser();
		        			conversationdetail.userDetails.userId = userSumary.id;
		        			conversationdetail.userDetails.name = userSumary.name;
		        		}
		        	}
		        	conversationdetail.userDetails.imageUrl = conversation.latestMessage.sender.photo.smallPhotoUrl;
		        	conversationdetail.cardColor = label.SF1ReadColorCode;
		            if(!conversation.read){
		            	conversationdetail.cardColor = label.Sf1UnreadColorCode;
		            }
		        listofAllPrivateConversations.add(conversationdetail);
			  }
			  if(listofAllPrivateConversations.size()==0){
	 	 			statusMessage = LABEL.SF1NoRecordLabel;
	 	 	  }
 	      }else{
 	      	statusMessage =  LABEL.SF1GuideUserforValidInput;
 	      }
 	  }catch(Exception e){
 	  	statusMessage = LABEL.SF1ErrorMessage; 	  	
 	  }
 }
 
 
 /*
 *@purpose  This function fetch all messages of any specific coversations that loggged in user has visited
 *@         When User clicks on any specific conversation this function returns all messages under specific conversation
 *@         ConnectApi getConversation(String conversationId) function is used to fetch  message list of any specific conversation based on conversation id.
 *@ Result : List of messages of any specific conversations
 */
  public void processMessagesofConversation(){
  	statusMessage = null;
  	showAllMessages = false;
	showMessageList = true; 
  	try{
 	//get fresh list
	 	if(selectedConversationId <> null){
	 	   lisofMessagesofSpecificConversation = new List<ConversationDetail>();
	 	   ConnectApi.ChatterConversation specificConversation = ConnectApi.ChatterMessages.getConversation(selectedConversationId);
	 	   for(ConnectApi.ChatterMessage chaterMessage:   specificConversation.messages.messages){
	 			 ConversationDetail conversationdetail = new ConversationDetail();
		        	conversationdetail.messageBody = chaterMessage.body.text;
		        	conversationdetail.relatedConversationId = chaterMessage.conversationId;
		        	conversationdetail.sentDate = chaterMessage.sentDate.format();	        	
		        	conversationdetail.userDetails = new ConversationUser();
		            conversationdetail.userDetails.userId = chaterMessage.sender.id;
		            conversationdetail.userDetails.name = chaterMessage.sender.name;
		            conversationdetail.userDetails.imageUrl = chaterMessage.sender.photo.smallPhotoUrl;
		         lisofMessagesofSpecificConversation.add(conversationdetail); 	
		         lastMessageId = chaterMessage.id;
	 		}
	 		//mark conversation Read
	 		ConnectApi.ChatterConversationSummary summary= ConnectApi.ChatterMessages.markConversationRead(selectedConversationId, true);
	 	 }
	 	 if(lisofMessagesofSpecificConversation.size()==0){
	 	 	statusMessage = LABEL.SF1NoRecordLabel;
	 	 }
  	 }catch(Exception e){
  	 	statusMessage = LABEL.SF1ErrorMessage;
  	 }
 }
 
 /*
 *@purpose  This function fetch all searched messages of any specific coversations that loggged in user has visited 
 *@         When User search for any messages under any specific conversation this function helps
 *@         ConnectApi searchConversation(String conversationId,String searchInput) function is used to fetch searched  message list of any specific conversation based on conversation id.
 *@ Result : List of searched messages of any specific conversations
 */
 public void processSearchMessagesofConversation(){
 	statusMessage = null;
 	showAllMessages = false;
 	showMessageList = true;
 	try{
	 	lisofMessagesofSpecificConversation = new List<ConversationDetail>();
system.debug('messageSearchString'+messageSearchString);
system.debug('messageSearchString'+messageSearchString.length());
system.debug('messageSearchString'+selectedConversationId);

	 	if(messageSearchString <> null && messageSearchString.length()>1 && selectedConversationId <> null){
            ConnectApi.ChatterConversation conversation = ConnectAPI.ChatterMessages.searchConversation(selectedConversationId,messageSearchString);
	 		system.debug('conversation'+conversation);
	 		system.debug('conversation.messages.messages'+conversation.messages.messages);

            for(ConnectApi.ChatterMessage chaterMessage:   conversation.messages.messages){
	 			 ConversationDetail conversationdetail = new ConversationDetail();
		        	conversationdetail.messageBody = chaterMessage.body.text;
		        	conversationdetail.relatedConversationId = chaterMessage.conversationId;
		        	conversationdetail.sentDate = chaterMessage.sentDate.format();	        	
		        	conversationdetail.userDetails = new ConversationUser();
		            conversationdetail.userDetails.userId = chaterMessage.sender.id;
		            conversationdetail.userDetails.name = chaterMessage.sender.name;
		            conversationdetail.userDetails.imageUrl = chaterMessage.sender.photo.smallPhotoUrl;
		         lisofMessagesofSpecificConversation.add(conversationdetail); 	
		         lastMessageId = chaterMessage.id;
		         
	 		}
	 		If(lisofMessagesofSpecificConversation.size() == 0){
	 			statusMessage = LABEL.SF1NoRecordLabel;
	 		}
 		}else{
 			statusMessage = LABEL.SF1GuideUserforValidInput; 
 		}
 	}catch(Exception e){
 		statusMessage = LABEL.SF1ErrorMessage;
 	}		
 }
 
 
 /*
 * @purpose  When user reply on any message this function takes messageBody,messageId and process reply Operation using ConnectApi 'replyToMessage' function
 */ 
 @remoteAction
 public static String processReplyonMessage(String messageBody,String messageId){
 	 ConnectApi.ChatterMessage  newMessage  =   ConnectApi.ChatterMessages.replyToMessage(messageBody, messageId);
 	 return newMessage.ConversationId;
 }
 
 /*
 *@purpose when user compose new message and send this function process send operation by Connectapi 'processSendNewMessage' function
 */
 @remoteAction
 public static String processSendNewMessage(String messageBody,String recipientId){
 	 ConnectApi.ChatterMessage  newMessage  =  ConnectAPI.ChatterMessages.sendMessage(messageBody,recipientId);
 	 return newMessage.ConversationId;
 }
 
 /*
 *@purpose this function autopopulate To address in sendmessage modal
 */
 @remoteAction
 public static List<UserDetails> processListofUsersforAutoPopulate(String searchString){
 	List<UserDetails> listofReturnUsers = new List<UserDetails>();
 	String compareString = '%'+searchString+'%';
 	for(User user: [select id,name,isActive from user where name like :compareString and id != :userinfo.getuserId() and isActive=true]){
 		UserDetails newUser = new UserDetails();
 	    newUser.label = user.name;
 		newUser.value = user.id;
 		listofReturnUsers.add(newUser);
 	}
 	return listofReturnUsers;
 }
 
 /*
 * Wrapper to autopopulate To user in New message Modal
 */
 public class UserDetails{
     public String label;
     public String value;
 }
}
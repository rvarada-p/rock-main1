/*
* Handler class for trigger
*/
public without sharing class ChatterMessageTrigerHandler {
    /*
    *@purpose This function Notify Receipient SF1 User When he/she received any private message
    *@Type of notofication :  'New private message received @ChatterAgent1 Please Visit : https://c.ap2.visual.force.com/apex/PrivateChatterMessage'
    *@Point to remember: We store notification record in Private_Notification__c object and we can get them by query on object only.This object need to be periodically archived so that new nitification always get space to insert. 
    */
    public static void processPrivateMessageNotification(List<ChatterMessage> listofChatterMessages){
        Map<String,MemberWrapper> mapofConversationIdandMemberDetails = new Map<String,MemberWrapper>();
        //populating senderId of the conversation

        set<Id> senderIdSet = new set<Id>();
        for(ChatterMessage chatterMessage : listofChatterMessages){
            MemberWrapper member = new MemberWrapper();
                member.senderId = chatterMessage.senderId;
                senderIdSet.add(chatterMessage.senderId);
            mapofConversationIdandMemberDetails.put(chatterMessage.conversationid,member);
        }
        Boolean senderIsChatterFree = false;
        for(User u:[SELECT Id, ProfileId, Profile.Name FROM User WHERE Id IN:senderIdSet]){
            if(u.Profile.Name == 'Tempo Chatter Free'){
                senderIsChatterFree = true;
            }
        }
        if(senderIsChatterFree==true){
            return;
        }
        //getting other member of the conversation as recipient
        for(ChatterConversationMember member : [SELECT Id, ConversationId, MemberId 
                                                FROM ChatterConversationMember 
                                                WHERE ConversationId IN : mapofConversationIdandMemberDetails.KeySet()]){
            
            MemberWrapper memberWrapper = mapofConversationIdandMemberDetails.get(member.ConversationId);                                       
            if(memberWrapper.senderId <>  member.MemberId){
                memberWrapper.recepeintId = member.MemberId;
                mapofConversationIdandMemberDetails.put(member.ConversationId,memberWrapper);
            }                                       
          }
          
          //Insert record for notification: This object records need to be archived periodically so that it has always space to insert record and feeds.
          Private_Notification__c notificationRecord;
          if(mapofConversationIdandMemberDetails.keyset().size() >0){
             notificationRecord = new Private_Notification__c();
             Database.insert(notificationRecord);
          }
          
          //Posting Feed to Notofy the Recipient User.Receipient user get a notification in bell with a link to visit private chatter page.Once he visits he can read  messages
          if(notificationRecord <> null){
            for(String conversationId : mapofConversationIdandMemberDetails.keyset()){
                MemberWrapper memberWrapper = mapofConversationIdandMemberDetails.get(conversationId);
            
                String communityId = null;
                ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
                
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegment;
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                ConnectApi.LinkSegmentInput  linkSegment = new ConnectApi.LinkSegmentInput();
                
                messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = LABEL.SF1NotificationMessage;
                messageInput.messageSegments.add(textSegment);
                
                mentionSegment.id = memberWrapper.recepeintId;
                messageInput.messageSegments.add(mentionSegment);
                
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = LABEL.SF1VisitMessage;
                messageInput.messageSegments.add(textSegment);
                
                linkSegment.url = URL.getSalesforceBaseUrl().toExternalForm() +LABEL.SF1PrivateMessagePageURL;              
                messageInput.messageSegments.add(linkSegment);
                
                
                input.body = messageInput;
                
                ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, notificationRecord.Id, input, null);
            }
          }    
    }
    
    public static void processChatterMessageForStudentEngagement(List<ChatterMessage> listofChatterMessages) {
      Set<Id> student = new Set<Id>();
      Map<Id, Id> senderConversationId = new Map<Id, Id>();
      Map<Id, Id> conversationSenderId = new Map<Id, Id>();
      Map<Id, Id> studentConversationId = new Map<Id, Id>();
      Map<Id, Id> receiverConversationMap = new Map<Id, Id>();
      List<String> tempoIds = new List<String>();
      List<Id> studentPrograms = new List<Id>();
      Map<Id, String> studentTempId = new Map<Id, String>();
      StudentProgramHelper stuProgHelper = new StudentProgramHelper();
      
      //Fetch TempoChatter profile id.
      Profile tempoChatterProfileId = [SELECT id FROM Profile WHERE name = 'Tempo Chatter Free' LIMIT 1];
      
      for(ChatterMessage msg : listofChatterMessages) {
        system.debug('ConversationId ' +msg.ConversationId);
        system.debug('SenderId ' +msg.SenderId);
        system.debug('Body ' +msg.Body);
        
        senderConversationId.put(msg.SenderId, msg.ConversationId);
        conversationSenderId.put(msg.ConversationId, msg.SenderId);         
      }
      
      system.debug('senderConversationId.keySet() ' +senderConversationId.keySet());
      system.debug('tempoChatterProfileId ' + tempoChatterProfileId.id);
      
      //Check if the sender is a Student.
      for(User usr : [SELECT id, Tempo_id__c FROM User WHERE id IN : senderConversationId.keySet() and profileId = : tempoChatterProfileId.id]) {
        studentConversationId.put(usr.id, senderConversationId.get(usr.id));
        studentTempId.put(usr.id, usr.Tempo_id__c); 
        system.debug('Added to studentConversationId ' + usr.id + ' ' + senderConversationId.get(usr.id)); 
      }
      
      //Fetch conversation members
      if(studentConversationId != null && studentConversationId.size() > 0) {
        for(ChatterConversationMember  member : [SELECT id, ConversationId, MemberId FROM ChatterConversationMember where ConversationId IN : StudentConversationId.values()]) {        
          if(!StudentConversationId.containsKey(member.MemberId)) {
            receiverConversationMap.put(member.MemberId, member.ConversationId);
            system.debug('Added to receiverConversationMap ' + member.MemberId + ' ' + member.ConversationId); 
          }
        }
      }
      
      //Check if the receiver is a faculty.
      if(receiverConversationMap != null && receiverConversationMap.size() > 0) {
        for(Program_Competency_Role__c role : [SELECT id, Faculty_Member__c from Program_Competency_Role__c WHERE Faculty_Member__c IN : receiverConversationMap.keySet()]) {
            student.add(conversationSenderId.get(receiverConversationMap.get(role.Faculty_Member__c)));
            system.debug('student ' + student);
        }
      }

      //Fetch tempo_id of student.
      
      for(Id studentId : student) {
        if(studentTempId.containsKey(studentId)) {
          tempoIds.add(studentTempId.get(studentId));
        }  
      }
         
      /*if(student != null && student.size() > 0) {
        for(User usr : [SELECT Tempo_id__c FROM User WHERE id IN : student]) {
            tempoIds.add(usr.Tempo_id__c);
        }
      }*/
      
      system.debug('tempoIds ' + tempoIds);
      
      //Fetch student program of the student through opportunity.
      if(tempoIds != null && tempoIds.size() > 0) {
        for(Opportunity oppty : [SELECT student_program__c FROM opportunity WHERE brand_profile__r.Tempo_Id__c IN : tempoIds]) {
          if(oppty.student_program__c != null) {
            system.debug('oppty id ' + oppty.id);
            studentPrograms.add(oppty.student_program__c);
          }
        }    
      }  
      
      system.debug('studentPrograms ' + studentPrograms);
      if(studentPrograms != null && studentPrograms.size() > 0) {
        stuProgHelper.logStudentEngagementByType(studentPrograms, 'Raise My Hand to SME', null);
      }
    }
        
    public Class MemberWrapper{
        public String senderId;
        public String recepeintId;
    }

}
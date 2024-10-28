/*******************************************************************
Name  : NoteTriggerHandler
Author: Tom (Appirio)
Date  : Feb 09, 2015
Description: single triggerHandler for Note
*************************************************************************/
public with sharing class NoteTriggerHandler {
	
  public final set<string> CBLRestrictedProfiles = new set<string>{'CBL Admissions Specialist'
                                                                  ,'CBL Enrollment Advisor'
                                                                  ,'CBL Bursar'
                                                                  ,'CBL Coach'
                                                                  ,'CBL Registrar'};

  public NoteTriggerHandler() {
	}

  public void cblEditDeletePrevention(list<Note> updatedNoteList){   
    Boolean isRestrictedProfile = false;
    for(Profile p:[SELECT Id FROM Profile WHERE Id =:UserInfo.getProfileId() AND Name IN :CBLRestrictedProfiles]){
      isRestrictedProfile = true;
    }
    if(isRestrictedProfile){
      for(Note note:updatedNoteList){
        if(note.isPrivate==false){
          note.addError(Label.CBL_Note_Restriction);
        }
      }
    }
  }

}
//***************************************************************************
// (c) 2013 Appirio, Inc.
//
// Description    : Class that returns the state of a given trigger and
//                : if it should execute when test methods are executed
//                  
// Sep 12, 2013   : Randy Wandell   Original  
//Sufia  -07/20/2021 : - S-685961 : test class issue fix
//   
//***************************************************************************/
public abstract class TriggerState {
    public static boolean isActive(String triggerName) {
        Map<String, TriggerSettings__c> triggerSetting = TriggerSettings__c.getAll();
        boolean isActive = true;
        try {
            if(triggerSetting.containsKey(triggerName)) {
                isActive = (Boolean)triggerSetting.get(triggerName).get('isActive__c');
            } else {
                addTriggerToSettings(triggerName);
            }
        } catch (Exception e) {
            system.debug('triggerSettings exception 11:::::::::::;'+e.getMessage()); 
        }
        return isActive;
    }
    /*
    public static boolean executeForTestMethods(String triggerName) {
        boolean isTestMode = true;
        try {
            if(triggerSetting.containsKey(triggerName)) {
                isTestMode = (Boolean)triggerSetting.get(triggerName).get('isTestMode__c');
            }
        } catch (Exception e) {
            system.debug('triggerSettings exception 22:::::::::::;'+e.getMessage()); 
        }
        return isTestMode ;
    }
    */
    
    private static void addTriggerToSettings(String triggerName) {
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = triggerName;
        triggerSettings.isActive__c = true;
        triggerSettings.isTestMode__c = true;
        insert triggerSettings;    
    }
}
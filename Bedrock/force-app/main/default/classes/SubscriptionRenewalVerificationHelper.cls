/************************************************************************
Name  : SubscriptionRenewalVerificationHelper
Author: Dirk Koechner (Appirio)
Date  : May, 2015
Description: helper class for batch class BatchSubscriptionRenewalVerification

Revision History:
Name                    Date               Story           Description
Ravitej Varada       Apr 17 2021        AZ 38396        6 Months SAP rules update
Ravitej Varada       Apr 17 2021        AZ 60122        6 Month SAP Rule update Prod defect to exclude transferred credits
Sufia                Jun 17 2022        S-695805        L2: Update Logic for SAP Code in L2
*************************************************************************/
public with sharing class SubscriptionRenewalVerificationHelper {

    public integer totalNumberOfGoodStanding;
    public integer totalNumberOfRenewalDeniles ;
    public integer totalNumberOfSuccess;
    public integer totalNumberOfFailure;

    public SubscriptionRenewalVerificationHelper() {
    }

    public void SubscriptionRenewalVerification(list<Student_Program__c> lstStudentProgram) {
        totalNumberOfGoodStanding = 0;
        totalNumberOfRenewalDeniles = 0;
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        list<Student_Program__c> lstStudentProgramForUpdate = new list<Student_Program__c>();
        list<SAP_History__c> lstSAPHistory = new list<SAP_History__c>();
        apexLogHandler.apexLog log;

        try {

            Date toDay = Date.today();

            // Run this script ONLY once / month, after the first Monday (where a new subscription period might have begun)
            // dayThisMonth >= 5: IF Verification scripts runs on Friday, MUST be at least 5th of month (so that the first Monday of the month has already past)
            // && dayThisMonth <= 11: AND first Friday of month (following a first Monday) can't be more than the 11th
            Integer dayThisMonth = toDay.day();
            system.debug('>> Today: day date:' + dayThisMonth);
            system.debug('>> Test.isRunningTest():' + Test.isRunningTest());
            //system.debug('>> TestDataGenerator.CheckDateOnSubscriptionRenewalVerification:' + Script_Settings__c.getValues('Current Settings').CheckDateOnSubscriptionRenewal__c);
            //if ((dayThisMonth < 5 || dayThisMonth > 11) && !Test.isRunningTest() && TestDataGenerator.CheckDateOnSubscriptionRenewalVerification) {
            if ((dayThisMonth < 5 || dayThisMonth > 11) && !Test.isRunningTest() && Script_Settings__c.getValues('Current Settings').CheckDateOnSubscriptionRenewal__c && Script_Settings__c.getValues('Current Settings').CheckDateOnSubscriptionRenewal__c != null) {
                system.debug('>> EXITING SUBSCRIPTION VERIFICATION - not Friday following first Monday of month, not running as a test');
                return;
            }

            // get all student hold code where Hold_Close_Date__c IS NULL or Hold_Close_Date__c > TODAY()
            map<ID, list<Student_Hold_Code__c>>mapStudentProgramWithStudentHoldCode = new map<ID, list<Student_Hold_Code__c>>();
            for (Student_Hold_Code__c sHoldCode : [
                    Select ID, Student_Program__c,Hold_Close_Date__c
                    from Student_Hold_Code__c
                    where Student_Program__c in:lstStudentProgram
                    and (Hold_Close_Date__c = null or Hold_Close_Date__c > :toDay )
            ]) {
                if (!mapStudentProgramWithStudentHoldCode.containsKey(sHoldCode.Student_Program__c)) {
                    mapStudentProgramWithStudentHoldCode.put(sHoldCode.Student_Program__c, new list<Student_Hold_Code__c>());
                }
                mapStudentProgramWithStudentHoldCode.get(sHoldCode.Student_Program__c).add(sHoldCode);
            }

            system.debug('>>>> SubscriptionRenewalVerification :::::::::::::::::::::   lstStudentProgram.size:' + lstStudentProgram.size());

            for (Student_Program__c sProgram : lstStudentProgram) {

                Boolean isUnderGradStudent = False;
                if (sProgram.Program__r.Degree_Level__c == 'Undergrad') {
                    isUnderGradStudent = true;
                }
                //
                // 1. Calculate: Satisfactory Academic Progress (SAP) - only after 1st term and every 6 months
                //

                system.debug('>> SAP + Renewal Verification for Program :::::::::::::::::::::: ' + sProgram.Name);

                sProgram.Renewal_Denied__c = false;
                String newSAPCode = '';
                String SAPLog = '';
                String renewalLog = '';

                integer numberCompletedTerms = (integer) sProgram.Number_of_Enrolled_Terms__c - 1;
                system.debug('numberCompletedTerms:' + numberCompletedTerms);

                decimal TBYBCredits = sProgram.Number_of_Credits_Completed_in_Trial__c;
                if (TBYBCredits == null)
                    TBYBCredits = 0;

                decimal TransferredCredits = sProgram.UG_GR_Transferred_Fulfilled_CE__c ;
                if (TransferredCredits == null)
                    TransferredCredits = 0;

                decimal CurrSubAttemptCred = sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c;
                if (CurrSubAttemptCred == null)
                    CurrSubAttemptCred = 0;

                decimal creditsBroughtIntoProgram = sProgram.Credits_Brought_into_Program__c;
                if (creditsBroughtIntoProgram == null)
                    creditsBroughtIntoProgram = 0;
 
                decimal CurrSubCredComplete = sProgram.Current_Student_Subscription__r.Number_of_Credits_Completed__c;
                if (CurrSubCredComplete == null)
                    CurrSubCredComplete = 0;

                // attemptedCreditsPriorTerms & earnedCreditsPriorTerms
                // 1) subtract out CLP attempted credits from current term from total attempted credits
                // 2) ADD Tbyb and transferred credits to both: attempted and earned values


                system.debug('sProgram.Total_attempted_credits__c' + sProgram.Total_attempted_credits__c);
                system.debug('CurrSubAttemptCred' + CurrSubAttemptCred);
                system.debug('Credits_Brought_into_Program__c' + creditsBroughtIntoProgram);
                system.debug('Number_Credits_Completed_in_all_Terms__c' + sProgram.Number_Credits_Completed_in_all_Terms__c);
                decimal attemptedCreditsPriorTerms = sProgram.Total_attempted_credits__c - CurrSubAttemptCred + creditsBroughtIntoProgram + TransferredCredits;
                decimal earnedCreditsPriorTerms = sProgram.Number_Credits_Completed_in_all_Terms__c - CurrSubCredComplete + creditsBroughtIntoProgram + TransferredCredits;
                system.debug('>> TOTAL Agreed To Credits Prior Terms (includes tbyb and transferred):' + attemptedCreditsPriorTerms);
                system.debug('>> TOTAL Earned Credits Prior Terms (includes tbyb and transferred):' + earnedCreditsPriorTerms);

                // Calculate # of months into program
                //   note: Application__r.Initial_Price_Book__r.Subscription_Duration_in_Months__c may be a range of months

                Date currentSubscriptionStartDate = sProgram.CurrentSubscriptionStartDate__c;
                Date firstStartDate = sProgram.First_Start_Date__c;
                system.debug(currentSubscriptionStartDate + '   ' + firstStartDate);
                if (currentSubscriptionStartDate == null || firstStartDate == null) {
                    system.debug('ERROR: either no currentSubscriptionStartDate OR First Start Date defined');
                    continue;
                }

                //Integer monthsIntoProgram = firstStartDate.monthsBetween(toDay);

                // S-335616 - DO SOMETHING LIKE THIS ONCE THE FIELD ON STUDENTPROGRAM HAS BEEN DEFINED
                // a person manually updates that new field on sp as needed.
                //Integer monthsIntoProgram = firstStartDate.monthsBetween(toDay) - (sProgram.totalNumbOfMonthsOnLOA__c!=null?sProgram.totalNumbOfMonthsOnLOA__c:0);
                Integer monthsIntoProgram = firstStartDate.monthsBetween(toDay) - (sProgram.LOA_Gap_Months__c != null ? Integer.valueOf(sProgram.LOA_Gap_Months__c) : 0);

                system.debug('Student monthsIntoProgram:' + monthsIntoProgram + '  (First Start Date:' + firstStartDate + ')');

                // TBD: Handle LOA here.
                // Assumption: a LOA extends the subscription period in which it occurs (eg. End_Date__c is pushed out)
                // monthsIntoProgram -= LOA Months

                Integer monthsIntocurrentterm = currentSubscriptionStartDate.monthsBetween(toDay);
                system.debug('Student subscription months into current term:' + monthsintocurrentterm + '  (currentSubscriptionStartDate:' + currentSubscriptionStartDate + ')');

                Integer LOA = (sProgram.LOA_Gap_Months__c != null ? Integer.valueOf(sProgram.LOA_Gap_Months__c) : 0);
                date nextSAPAssessmentMonth = null;
                datetime nextSAPDate = null;

                // only calculate if student has completed first term
                if (numberCompletedTerms > 0) {

                    /*  // Student has completed first term, and is in 1st month of second term
                      if(numberCompletedTerms == 1 && monthsintocurrentterm == 0) {

                          system.debug('>> numberCompletedTerms == 1 && monthsintocurrentterm == 0');
                          system.debug('sProgram.Number_of_Competencies_Completed__c:'+sProgram.Number_of_Competencies_Completed__c);
                          system.debug('sProgram.Competencies_Completed_in_Trial__c:'+sProgram.Competencies_Completed_in_Trial__c);

                          // Check that at least 2 competencies are completed in first term
                          // confirmed:tbyb is NOT included in 1st term condition (>= 2 competencies completed)
                          //If competencies completed are >=2
                          if (sProgram.Number_of_Competencies_Completed__c  >= 2) {
                              //Modality Switcher - If students previous SAP Code = W-Warning then when the 3 month (1st Term) SAP evaluation happens - if the student met the criteria (completed 2 academic competencies) then update SAP Code = W - Warning
                              if(sProgram.Modality_Switcher_chk__c && sProgram.SAP_Code__c == 'W - Warning') {
                                  newSAPCode = 'W - Warning';
                                  SAPLog += ' First term, # competencies completed >=2. ';
                              }
                              //Not a modality switcher
                              else {
                                  newSAPCode = 'S - Satisfactory';
                                  SAPLog += 'First term, # competencies completed >=2 ';
                                  //SAPLog += 'First term, # competencies completed >= 2. ';
                              }
                          }
                          //If competencies compeleted are not >=2 and the student is a modality switcher who was previously on warning put then on D - Denied
                          else if(sProgram.Modality_Switcher_chk__c && sProgram.SAP_Code__c == 'W - Warning') {
                              sProgram.Renewal_Denied__c = true;
                              newSAPCode = 'D - Denied';
                              SAPLog += ' First term, # competencies completed < 2 ';
                          }
                          //All other students who didn't complete the competencies to be placed on Warning
                          else{
                              newSAPCode = 'W - Warning';
                              SAPLog += ' First term, # competencies completed < 2 ';
                          }

                        //Next SAP DATE Logic
                        nextSAPAssessmentMonth = firstStartDate.addMonths(6 + LOA);
                        nextSAPDate = DateTime.newInstance(nextSAPAssessmentMonth.year(), nextSAPAssessmentMonth.month(), 5);
                        while(!nextSAPDate.format('EEEE').equalsIgnoreCase('Friday') && nextSAPDate.day() < 12){
                            nextSAPDate = nextSAPDate.addDays(1);
                        }
                          sProgram.Next_SAP_Date__c = Date.valueOf(nextSAPDate);
                      }*/

                    // Student has completed 6 months of program, calc SAP for prior terms
                    if (monthsIntoProgram == 6) {
                        system.debug('>> monthsIntoProgram == 6');
                        system.debug('>> earnedCreditsPriorTerms ' + earnedCreditsPriorTerms);
                        system.debug('>> attemptedCreditsPriorTerms ' + attemptedCreditsPriorTerms);
                        system.debug('>> attemptedCreditsPriorTerms ' + sProgram.Program__r.Degree_Level__c);
                        system.debug('>> attemptedCreditsPriorTerms ' + sProgram.Number_Credits_Completed_in_all_Terms__c);
                         system.debug('>> attemptedCreditsPriorTerms ' + CurrSubCredComplete);
  
                        //60122
                         if ((sProgram.Program__r.Degree_Level__c == 'Graduate' &&  ( sProgram.Number_Credits_Completed_in_all_Terms__c - CurrSubCredComplete ) < 2)||(sProgram.Program__r.Degree_Level__c == 'Undergrad' &&  ( sProgram.Number_Credits_Completed_in_all_Terms__c  - CurrSubCredComplete) < 3)) {
                             system.debug('>> Denied IF Condition ');

                            sProgram.Renewal_Denied__c = true;
                            newSAPCode = 'D - Denied';
                            
                            if (isUnderGradStudent) {
                                SAPLog += ' First term, # competencies completed < 3';
                            } else {
                                SAPLog += ' First term, # competencies completed < 2';
                            }
                        } else if ((sProgram.Program__r.Degree_Level__c == 'Graduate' && (earnedCreditsPriorTerms >= (attemptedCreditsPriorTerms / 2)) && earnedCreditsPriorTerms >= 2) ||
                                   (sProgram.Program__r.Degree_Level__c == 'Undergrad' && (earnedCreditsPriorTerms >= (attemptedCreditsPriorTerms * 0.67)) && earnedCreditsPriorTerms >= 3)) {
                           system.debug('>> Satisfactory IF Condition ');

                            newSAPCode = 'S - Satisfactory';
                            if (isUnderGradStudent) {
                                SAPLog += 'Earned Credits Prior Terms >= (Agreed To Credits Prior Terms x 0.67). ';
                            } else {
                                SAPLog += 'Earned Credits Prior Terms >= (Agreed To Credits Prior Terms / 2). ';
                            }

                        } else if (
                                (sProgram.Program__r.Degree_Level__c == 'Graduate' && (earnedCreditsPriorTerms < (attemptedCreditsPriorTerms / 2)) && earnedCreditsPriorTerms >= 2) ||
                                        (sProgram.Program__r.Degree_Level__c == 'Undergrad' && (earnedCreditsPriorTerms < (attemptedCreditsPriorTerms * 0.67)) && earnedCreditsPriorTerms >= 3)) {
                           system.debug('>> Warning IF Condition ');
                            newSAPCode = 'W - Warning';

                            if (isUnderGradStudent) {
                                SAPLog += ' 67% of agreed to credits not achieved. ';
                            } else {
                                SAPLog += ' 50% of agreed to credits not achieved. ';
                            }
                         } 
                        //Next SAP Date Logic for 6 Months check
                        nextSAPAssessmentMonth = firstStartDate.addMonths(12 + LOA);
                        nextSAPDate = DateTime.newInstance(nextSAPAssessmentMonth.year(), nextSAPAssessmentMonth.month(), 5);
                        while (!nextSAPDate.format('EEEE').equalsIgnoreCase('Friday') && nextSAPDate.day() < 12) {
                            nextSAPDate = nextSAPDate.addDays(1);
                        }
                        sProgram.Next_SAP_Date__c = Date.valueOf(nextSAPDate);
                    }

                    // Student's numberCompletedTerms is in 6 month increments (eg. 12, 18, 24, ...), calc SAP for prior terms
                    else if (math.mod(monthsIntoProgram, 6) == 0) {

                        system.debug('>> monthsIntoProgram == 12,18,24,etc.');
                        system.debug('Current SAP_Code__c:' + sProgram.SAP_Code__c);
                        // if credits earned >= 50% of attempted credits
                        if ((earnedCreditsPriorTerms >= (attemptedCreditsPriorTerms / 2) && sProgram.Program__r.Degree_Level__c == 'Graduate') || (earnedCreditsPriorTerms >= (attemptedCreditsPriorTerms * 0.67) && sProgram.Program__r.Degree_Level__c == 'Undergrad')) {
                            newSAPCode = 'S - Satisfactory';
                            if (isUnderGradStudent) {
                                SAPLog += 'Earned Credits Prior Terms >= (Agreed To Credits Prior Terms x 0.67). ';
                            } else {
                                SAPLog += 'Earned Credits Prior Terms >= (Agreed To Credits Prior Terms / 2). ';
                            }
                        } else {
                            system.debug('sProgram.SAP_Code__c ' + sProgram.SAP_Code__c);
                            if (isUnderGradStudent) {
                                SAPLog += 'Earned Credits Prior Terms < (Agreed To Credits Prior Terms x 0.67).';
                            } else {
                                SAPLog += 'Earned Credits Prior Terms < (Agreed To Credits Prior Terms / 2). ';
                            }
                            if (sProgram.SAP_Code__c == null || sProgram.SAP_Code__c == 'S - Satisfactory') {
                                newSAPCode = 'W - Warning';
                            } else if (sProgram.SAP_Code__c == 'W - Warning') {
                                newSAPCode = 'D - Denied';

                                if (isUnderGradStudent) {
                                    SAPLog += 'Student with prior SAP warning and 67% of agreed to credits not achieved. ';
                                } else {
                                    SAPLog += 'Student with prior SAP warning and 50% of agreed to credits not achieved. ';
                                }
                                sProgram.Renewal_Denied__c = true;
                            }
                        }


                        //Next SAP DATE LOGIC for 12, 18,24...... Months check
                        nextSAPAssessmentMonth = firstStartDate.addMonths(monthsIntoProgram + 6 + LOA);
                        nextSAPDate = DateTime.newInstance(nextSAPAssessmentMonth.year(), nextSAPAssessmentMonth.month(), 5);
                        while (!nextSAPDate.format('EEEE').equalsIgnoreCase('Friday') && nextSAPDate.day() < 12) {
                            nextSAPDate = nextSAPDate.addDays(1);
                        }
                        sProgram.Next_SAP_Date__c = Date.valueOf(nextSAPDate);
                    }

                }
                //
                // 2. Subscription Renewal. Check the following ONLY IF 5 days within last renewal period:
                //           a) Holds OR b) if all competencies completed OR c) if admissions contingency set
                //           If so, set Renewal_Denied flag + comments
                //


                Date fourDayAgoDate = toDay.addDays(-4);
                if (currentSubscriptionStartDate < toDay && currentSubscriptionStartDate >= fourDayAgoDate) { // jan 28th  ( 24,25,26,27 )

                    system.debug('>> Student Subscription renewed in last 4 days:' + currentSubscriptionStartDate);
                    // check if there are any Student Hold Codes on the student program WHERE Hold_Close_Date__c IS NULL or > TODAY().  If  >0 rows:
                    if (mapStudentProgramWithStudentHoldCode.containsKey(sProgram.id) && mapStudentProgramWithStudentHoldCode.get(sProgram.id).size() > 0) {
                        sProgram.Renewal_Denied__c = true;
                        renewalLog += 'Student has active holds. ';
                    }

                    decimal competenciesCompleted = 0;
                    if (sProgram.Number_of_Competencies_Completed__c != null) {
                        competenciesCompleted = sProgram.Number_of_Competencies_Completed__c;
                    }

                    if (sProgram.Number_of_Competencies_Transferred__c != null) {
                        competenciesCompleted += sProgram.Number_of_Competencies_Transferred__c;
                    }

                    if (sProgram.Competencies_Completed_in_Trial__c != null) {
                        competenciesCompleted += sProgram.Competencies_Completed_in_Trial__c;
                    }
                    system.debug('*****competenciesCompleted' + competenciesCompleted);
                    if (competenciesCompleted == sProgram.Number_of_Competencies__c) {
                        sProgram.Renewal_Denied__c = true;
                        renewalLog += 'Student has completed all competencies in student program. ';
                    }

                    // TBD: do not set the renewal denied flag IF contingency is set AND 
                    // This is the student's first subscription
                    if (sProgram.Application__c != null && sProgram.Application__r.Admissions_Contingency__c == 'Not Cleared' && sProgram.First_Start_Date__c != sProgram.CurrentSubscriptionStartDate__c) {
                        sProgram.Renewal_Denied__c = true;
                        renewalLog += 'Student admissions contingency is not cleared. ';
                    }

                }


                // Log SAP and Renewal status, add to update list
                if (newSAPCode != '' || sProgram.Renewal_Denied__c) {
                    String logComments = '';
                    if (newSAPCode != '') {
                        sProgram.Previous_SAP_Code__c = sProgram.SAP_Code__c;
                        sProgram.SAP_Code__c = newSAPCode;
                        sProgram.SAP_Date__c = toDay;
                        logComments = '[' + toDay.format() + '] SAP Code: ' + newSAPCode
                                + '. Months Into Program:' + monthsIntoProgram
                                + '. Earned Credits Prior Terms:' + earnedCreditsPriorTerms
                                + '. Agreed To Credits Prior Terms:' + attemptedCreditsPriorTerms
                                + '. ' + SAPLog + '\n';
                        sProgram.Renewal_Denied_Comment__c = logComments;
                    }

                    if (sProgram.Renewal_Denied__c && newSAPCode != '') {
                        totalNumberOfRenewalDeniles++;
                        sProgram.SAP_Date__c = toDay;
                        logComments = '[' + toDay.format() + '] Renewal Denied: ' + renewalLog + '\n';
                        sProgram.Renewal_Denied_Comment__c += logComments;
                    } else if (sProgram.Renewal_Denied__c && newSAPCode == '') {
                        totalNumberOfRenewalDeniles++;
                        //sProgram.SAP_Date__c = toDay;
                        logComments = '[' + toDay.format() + '] Renewal Denied: ' + renewalLog + '\n';
                        sProgram.Renewal_Denied_Comment__c += logComments;
                    }

                    SAP_History__c sapHistory = new SAP_History__c(Student_Program__c = sProgram.Id, SAP_Code__c = newSAPCode, SAP_Date__c = toDay, Renewal_Comment_Log__c = logComments);
                    lstSAPHistory.add(sapHistory);
                    lstStudentProgramForUpdate.add(sProgram);
                    system.debug(sProgram.Renewal_Denied_Comment__c);
                }

            }  // end for(Student_Program__c sProgram

            if (!lstStudentProgramForUpdate.isEmpty() && !lstSAPHistory.isEmpty()) {
                Database.Saveresult[] saveResult = Database.update(lstStudentProgramForUpdate, false);
                Database.Saveresult[] sapResult = Database.insert(lstSAPHistory, false);
                for (Database.SaveResult sr : saveResult) {
                    if (sr.isSuccess()) {
                        totalNumberOfSuccess++;
                    } else {
                        // Operation failed, so get all errors                
                        totalNumberOfFailure++;
                    }
                }
            }
        } catch (exception ex) {
            //log = new apexLogHandler.apexLog('SubscriptionRenewalVerificationHelper','SubscriptionRenewalVerification', ex.getMessage());
        } finally {
            /*if(log != null){
                log.saveLogs();
             }*/
        }
        //log.saveLogs();
    }

}
/*******************************************************************
Name  : Constants
Author: Sufia
Date  : June 28, 2021
Description: Util class to contain all constant values to be used in the org

* Revision History
* Sufia             - June 28, 2021 - User Story S-685520
* Horacio Sanchez   - Jul 07, 2021  - Bug 58157: Business Essentials Fulfilled SC's and SE's are not changing to Registered when MBA2 attribute is deleted in L2
*************************************************************************/

public class Constants {
	public static final String CLEARED_STRING = 'Cleared';
    public static final String NOT_CLEARED_STRING = 'Not Cleared';
    public static final String FULFILLED_STRING = 'Fulfilled';
    public static final String REGISTERED_STRING = 'Registered';

    
    public static final String CONTINGENT_STRING = 'Contingent';
    public static final String CONTINGENT_CLEARED_STRING = 'Contingency Cleared';
    
    public static final List<String> BECompetenciesList1 = new List<String>{ 'BE001','BE002','BE003','BE004','BE005' };
}
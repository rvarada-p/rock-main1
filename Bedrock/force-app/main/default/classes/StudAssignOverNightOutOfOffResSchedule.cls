global class StudAssignOverNightOutOfOffResSchedule implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CustomerSupportTeamReset cst = new CustomerSupportTeamReset();
        cst.OvernightReset();
    }
}
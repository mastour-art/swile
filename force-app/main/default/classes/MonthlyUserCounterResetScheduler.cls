public class MonthlyUserCounterResetScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ResetUserAssignmentCounterBatch());
    }
}
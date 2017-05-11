public class RemoveUnusablePaymentHistories implements Schedulable{
    private final Set<String> applicationStatusesWithUnusablePaymentHistories = new Set<String>{'Cancelled-By Neyber', 'Completed'}; //statuses of application where payment histories will be deleted

    public void execute(SchedulableContext sc){
//        List<Payment_History__c> paymentHistories = [   SELECT Id
//                                                        FROM PaymentHistory__c
//                                                        WHERE Debt_Analysis__r.genesis__Applications__r.genesis__Status__c IN :applicationStatusesWithUnusablePaymentHistories];
//        delete paymentHistories;
    }
}
global class ClearNotation implements Schedulable{

	global void execute(SchedulableContext SC) {
		List<Notation__c> notations = [SELECT Id FROM Notation__c ORDER BY NoteTime__c DESC OFFSET 10];
		delete notations;
	}
}
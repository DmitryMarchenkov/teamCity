@isTest
private class MainPageControllerTest {
	
	@isTest 
	static void testInsertNotation() {
		Integer notationsCount = 10;
		TestSetup testSetup = new TestSetup();

		Test.startTest();
			testSetup.insertNotations(notationsCount);
		Test.stopTest();

		List<Notation__c> notations = [SELECT Id FROM Notation__c WHERE Note__c LIKE 'I am test notation%'];
		System.assertEquals(notationsCount, notations.size(), 'Count of notations not expected!');
	}

	@isTest
	public static void testDeleteNotation() {
		Integer notationsCount = 20;
		TestSetup testSetup = new TestSetup();
		testSetup.insertNotations(notationsCount);

		Test.startTest();
			ClearNotation scheduleClass = new ClearNotation();
			String sch = '0 0 1 * * ?';
			String jobID = system.schedule('Clear Notation', sch, scheduleClass);
		Test.stopTest();

 		CronTrigger ct = [	SELECT Id, CronExpression, TimesTriggered, NextFireTime
         					FROM CronTrigger 
         					WHERE id = :jobID];

        System.assertEquals(sch, ct.CronExpression);

		List<Notation__c> notations = [SELECT Id FROM Notation__c WHERE Note__c LIKE 'I am test notation%'];
		System.assertEquals(10, notations.size(), 'Scheduled class did not delete notations!');
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}

	private class TestSetup {
		public MainPageController controller;
		public Notation__c notation;

		public TestSetup() {
			controller = new MainPageController();
		}

		public void insertNotations(Integer count) {
			List<Notation__c> notations = new List<Notation__c>();
			for(Integer i = 0; i < count; i++) {
				notation = new Notation__c();
				notation.Note__c = 'I am test notation' + i;
				notations.add(notation);
			}
			insert notations;
		}
	}
	
}
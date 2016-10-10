@RestResource(urlMapping='/DragAndDrop/schedule/*')
global with sharing class DragAndDropScheduleUploadService
{
    @HttpPost
    global static void attachDoc(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		res.addHeader('Access-Control-Allow-Origin', 'https://c.eu11.visual.force.com/apex/MainPage');
		res.addHeader('Content-Disposition', 'attachment');

        String fName = req.params.get('FileName');
		fName += '.';
		String fRes = req.params.get('FileResolution');
        Date scheduleDate = date.valueOf(req.params.get('ScheduleDate'));
        Blob postContent = req.requestBody; 

		List<Schedule__c> scheduleToDelete = [SELECT Id, ScheduleDate__c FROM Schedule__c WHERE ScheduleDate__c =: scheduleDate];
		if(!scheduleToDelete.isEmpty()) {
			delete scheduleToDelete;
		}

		Schedule__c schedule = new Schedule__c();
		schedule.ScheduleDate__c = scheduleDate;
		insert schedule;
		Id parentId = schedule.Id;

		Attachment attachment = new Attachment (ParentId = parentId,
                                   Body = postContent,
                                   Name = fName+fRes);

		insert attachment;
		System.debug(loggingLevel.Error, '*** schedule: ' + schedule);
		System.debug(loggingLevel.Error, '*** attachment: ' + attachment);
   }
}
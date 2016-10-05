@RestResource(urlMapping='/DragAndDrop/v1/*')
global with sharing class DragAndDropFileUploadService
{
    @HttpPost
    global static String attachDoc(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		res.addHeader('Access-Control-Allow-Origin', 'https://c.eu11.visual.force.com/apex/MainPage');
		res.addHeader('Content-Disposition', 'attachment');

																									System.debug(loggingLevel.Error, '*** : 0' + req);
        String fName = req.params.get('FileName');
		fName += '.';
		String fRes = req.params.get('FileResolution');	
        String materialName = req.params.get('MaterialName');
        String materialTheme = req.params.get('MaterialTheme');
		Boolean isDoc = false;

		if (!String.isBlank(req.params.get('isDoc'))){
			isDoc = Boolean.valueOf(req.params.get('isDoc'));
		}

        Blob postContent = req.requestBody; 

		if (isDoc)
		{
			Document d = new Document(FolderId = UserInfo.getUserId(),
									  Body = postContent,
									  Name = fName+fRes,
									  IsPublic = true);
			insert d;
			
			System.debug(d);
			return d.id;
		}
		else
		{
			List<Material__c> materials = [SELECT Id, Name, Theme__c FROM Material__c WHERE Name = :materialName AND Theme__c = :materialTheme];
			Id parentId;
			if(materials.isEmpty()) {
				Material__c material = new Material__c();
				material.Name = materialName;
				material.Theme__c = materialTheme;
				insert material;
				parentId = material.Id;
			} else {
				parentId = materials[0].Id;
			}
				Attachment a = new Attachment (ParentId = parentId,
	                                       Body = postContent,
	                                       Name = fName+fRes);
				insert a;
				return a.Id;
			
		}   
   }
}
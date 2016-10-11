global with sharing class MainPageController {
	public String selectedTheme { get;set; }
	public String inputNotation { get;set; }
	public List<SelectOption> statusOptionsTheme { get;set; }
    public List<Material__c> materials { get;set; }
    public List<Notation__c> notations { get;set; }
    public Map<Id, List<Attachment>> materialsWithAttachment {get;set;}
    public Date scheduleDate {get; set;}
    public Attachment scheduleImg {get; set;}
    public Boolean showScheduleFlag {get; set;}
    public String mainPageTitle {get; set;}
    
	public MainPageController() {
		getPicklistValuesTheme();
		showMaterials();
		showNotations();
		scheduleDate = Date.today();
		showSchedule();
	}

    public PageReference showMaterials() {
        materialsWithAttachment = new Map<Id, List<Attachment>>();
        Map<Id, Material__c> materialsMap = new Map<Id, Material__c>([SELECT Id, Name FROM Material__c WHERE Theme__c = :selectedTheme ORDER BY Name]);
        Set<Id> materialsIds = materialsMap.keySet();
        materials = materialsMap.values();

        for(Attachment attachment: [SELECT Id, ParentId, Name FROM Attachment WHERE ParentId IN :materialsIds]) {
        	if(materialsWithAttachment.containsKey(attachment.ParentId)) {
        		materialsWithAttachment.get(attachment.ParentId).add(attachment);
        	} else {
        		List<Attachment> attachments = new List<Attachment>();
        		attachments.add(attachment);
            	materialsWithAttachment.put(attachment.ParentId, attachments);
        	}
        }
        removeMaterialsWithoutAttachment();
        return null;
    }

    public PageReference showSchedule() {
    	getScheduleByDate(scheduleDate);
    	return null;
    }

    public PageReference showNotations() {
    	notations = [SELECT Id, Note__c, NoteTime__c FROM Notation__c ORDER BY NoteTime__c DESC LIMIT 20];
    	return null;
    }

    public PageReference getScheduleByDate(Date choosedScheduleDate) {
    	List<Schedule__c> schedules;
    	if(choosedScheduleDate == null) {
    		schedules = [SELECT Id, ScheduleDate__c FROM Schedule__c WHERE ScheduleDate__c = TODAY LIMIT 1];
    	} else {
    		schedules = [SELECT Id, ScheduleDate__c FROM Schedule__c WHERE ScheduleDate__c = :choosedScheduleDate LIMIT 1];
    	}

    	try {
    		scheduleImg = [SELECT Id FROM Attachment WHERE ParentId = :schedules[0].Id];
    		showScheduleFlag = true;
    	} catch(Exception e) {
    		showScheduleFlag = false;
    		scheduleImg = null;
    		addErrorMessage('Schedule on this date does not exist!');
    	} finally {
            if(!showScheduleFlag) {
                mainPageTitle = ' does not exist ';
            }
        }
    	return null;
    }

    private void removeMaterialsWithoutAttachment() {
    	List<Material__c> materialsToDelete = new List<Material__c>();
        for(Integer i = 0; i < materials.size(); i++) {
        	if(!materialsWithAttachment.containsKey(materials[i].Id)) {
        		materialsToDelete.add(materials[i]);
        		materials.remove(i);
        	}
        }
        delete materialsToDelete;
    }

	public void getPicklistValuesTheme() {
        Schema.DescribeFieldResult statusFieldDescription = Material__c.Theme__c.getDescribe();
        statusOptionsTheme = getPicklistValues(statusFieldDescription);
    }

    private List<SelectOption> getPicklistValues(Schema.DescribeFieldResult statusFieldDescription) {
    	List<SelectOption> tmpStatusOptions = new List<SelectOption>();
    	for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            tmpStatusOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
        return tmpStatusOptions;
    }


    public PageReference saveNotations() {
    	if(!(inputNotation.trim().length() == 0)) {
    		Notation__c notation = new Notation__c();
    		Datetime noteTime = Datetime.now();
    		notation.Note__c = inputNotation;
    		notation.NoteTime__c = noteTime;
    		insert notation;
    		showNotations();
    	}
    	return null;
    }

	public PageReference removeNotation(){	
		String notationId = getParameterByName('removeNotationId');
		List<Notation__c> notationIds = [SELECT Id FROM Notation__c WHERE Id =: notationId];
		delete notationIds;
		showNotations();
        return null;
	}

	public PageReference removeAttachment(){
		String attachmentId = getParameterByName('removeAttachmentId');
		List<Attachment> attachmentIds = [SELECT Id FROM Attachment WHERE Id =: attachmentId];
		delete attachmentIds;
		showMaterials();
        return null;
	}

	public PageReference removeMaterial(){
		String materialId = getParameterByName('removeMaterialId');
		List<Material__c> materialIds = [SELECT Id FROM Material__c WHERE Id =: materialId];
		delete materialIds;
		showMaterials();
        return null;
	}

	private String getParameterByName(String parameterName) {
		String sObjectId = ApexPages.currentPage().getParameters().get(parameterName);
		return sObjectId;
	}  

	private void addErrorMessage(String mess) {
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, mess);
        ApexPages.addMessage(errorMessage);
    }
}
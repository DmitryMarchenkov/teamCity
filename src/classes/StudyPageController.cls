public with sharing class StudyPageController {

    public List<SelectOption> selectOptions {get; set;}
    public String selectedSObj {get; set;}
    public List<sObjectWrapper> sObjectWrappers {get; private set;}
    public Boolean hasName {get; private set;}
    public Boolean objectChoosed {get; private set;}

    public StudyPageController(){
        this.sObjectWrappers = new List<sObjectWrapper>();
        hasName = false;
        objectChoosed = false;
        prepareSObject();
    }

    public void prepareSObject(){
        selectOptions = new List<SelectOption>();
        this.selectOptions.add(new SelectOption('none', '---None---'));
        Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
        List<String> sObjs = new List<String>(globalMap.keySet());
        
        for (String sObj : sObjs) {
            if (globalMap.get(sObj).getDescribe().isAccessible() == true && globalMap.get(sObj).getDescribe().isUpdateable() == true){
                selectOptions.add(new SelectOption(sObj, globalMap.get(sObj).getDescribe().getLabel()));
            }
        }
        this.selectedSObj = 'none';
    }

    public void executeSelect(){
        if (!objectChoosed) {
            this.sObjectWrappers = new List<sObjectWrapper>();
            String fieldList = 'Id';
            if (doesFieldExist(selectedSObj, 'Name')) {
                fieldList += ', Name';
                this.hasName = true;
            }

            String selectString = 'SELECT ' + fieldList + ' FROM ' +  selectedSObj + ' LIMIT 1000';

            if (this.selectedSObj != null && this.selectedSObj != 'none') {
                List<SObject> sObjectsList = Database.query(selectString);

                for (SObject sobj : sObjectsList) {
                    sObjectWrappers.add(new sObjectWrapper(sobj));
                }
            }
            objectChoosed = true;
        } else {
            objectChoosed = false;
        }
    }

    public void deleteSelectedRecords(){
        List<sObject> sObjectstoDelete = new List<sObject>();
        for (sObjectWrapper wrap : sObjectWrappers) {
            if (wrap.deleteThis == true) {
                sObjectstoDelete.add(wrap.sssObject);
            }
        }
        delete sObjectstoDelete;
        executeSelect();
    }

    private Boolean doesFieldExist(String objName, String fieldName) {
        List<Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().values();
        Set<String> fieldNames = new Set<String>();
        for (Schema.SObjectField fld : fields) {
            fieldNames.add(fld.getDescribe().getName());
        }
        return (fieldNames.contains(fieldName));
    }

    public class sObjectWrapper {
        public Boolean deleteThis {get; set;}
        public Object name {get; private set;}
        public Object id {get; private set;}
        public SObject sssObject {get; private set;}

        public sObjectWrapper(SObject sObj) {
            this.sssObject = sObj;
            this.id = this.sssObject.get('Id');

            try {
                this.name = this.sssObject.get('Name');
            } catch (Exception e){
                System.debug('::DEBUG:: Object do not have a name!');
            }
        }
    }
}
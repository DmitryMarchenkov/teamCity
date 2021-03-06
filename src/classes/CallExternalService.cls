public class CallExternalService {
    public CallExternalService() {}
    
    public void getUser() { //add id or name as inner parameter
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');   //necessary to add endpoint remote site
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('res' + results);
            // Cast the values in the 'animals' key as a list
            List<Object> animals = (List<Object>) results.get('animals');
            System.debug('Received the following animals:');
            
//            List<Animal__c> animalsForInsert = new List<Animal__c>();
//            for (Object animal: animals) {
//                System.debug(animal);
//                Animal__c a = new Animal__c();
//                a.Name = (String) animal;
//                animalsForInsert.add(a);
//            }
//            insert animalsForInsert;
        }
		System.debug('::DEBUG:: not only class');
    }
}
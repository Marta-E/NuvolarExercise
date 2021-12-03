public without sharing class flightCreator {
  
        @AuraEnabled
    public static List<String> airportList(){
        List<String> listAirport = new List<String>();

        Airport__c[] airportListObject= [SELECT IATA__c FROM  Airport__c];

        for ( Airport__c o : airportListObject) {
            listAirport.add(o.IATA__c);
        }

         
         System.debug(listAirport);
        return listAirport;
    }

        
    @AuraEnabled
    public static Flight__c createFlight (String departure, String arrival){

        //Checks if the Flight already exist
        Flight__c[] flightExists=[SELECT Id FROM Flight__c WHERE  Departure_Airport__r.IATA__c LIKE :departure AND Arrival_Airport__r.IATA__c  LIKE :arrival LIMIT 1];

        System.debug(flightExists);
        //If there isn't a match, proceeds to create the flight
        if(flightExists.isEmpty()){
           
            //Retrieves the data from the two airports records
            Airport__c arr= [SELECT Id, Name, IATA__c, Latitude__c,Longitude__c  FROM  Airport__c WHERE IATA__c LIKE :arrival LIMIT 1];
            Airport__c dep= [SELECT Id, Name, IATA__c, Latitude__c,Longitude__c  FROM  Airport__c WHERE IATA__c LIKE :departure LIMIT 1];
            
            //Calculates de distance with the method provided
            Decimal arrLong= arr.Longitude__c;
            Decimal  arrLat=arr.Latitude__c;
            Decimal depLong=dep.Longitude__c;
            Decimal depLat=dep.Latitude__c;
            Decimal distance= calculateDistance(arrLat,  arrLong, depLong, depLat);

            //Creates the flight record
            Flight__c flight = new Flight__c();
            flight.Name=dep.name+'-'+arr.name;
            flight.Departure_Airport__c=dep.Id;
            flight.Arrival_Airport__c=arr.Id;
            flight.Distance__c=distance;

            try {
                INSERT flight;
            }
            catch (Exception e) {
                // If there is a problem in the insertion retrieves the code to display it as a Toast
                throw new AuraHandledException(e.getMessage());    
            }
           //Retrieves the information of the inserted object and returns it to the component to display it
            Flight__c flightReturn=[SELECT Distance__c, Name, Departure_Airport__r.IATA__c, Arrival_Airport__r.IATA__c FROM Flight__c WHERE Id= : flight.Id];

            return flightReturn;
        }
        //If the flight already exists returns an error message
        else {
            throw new AuraHandledException('The flight already exists');   
            //return null;            
        }

    }

    public static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371 * 1000; // in meters
        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
        Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
        Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance*0.001;// to return them in kilometres
    }
}
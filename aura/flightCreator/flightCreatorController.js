({
    doInit: function (component, event, helper) {

        var options = [
        ];

        let airportList = component.get('c.airportList');


        airportList.setCallback(this, response => {
            if (response.getState() === 'ERROR') {
            }

            else if (response.getState() === 'SUCCESS') {

                var arr = response.getReturnValue();
                console.log(arr);

                arr.forEach(function (element) {
                    options.push({ value: element, label: element });
                });

                console.log(options);
                component.set("v.statusOptions", options);

            }
        });
        $A.enqueueAction(airportList);
    },

    handleClick: function (component, event, helper) {
        console.log('buenas');
        var departure = component.find("departure").get("v.value");
        var arrival = component.find("arrival").get("v.value");

        //If values are the same shows error message
        if(departure==arrival){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "The Departure and the Arrival can't be the same."
            });
            toastEvent.fire();
        }

        //If values are not equal proceeds to create flight
        else{
            var action = component.get("c.createFlight");
            action.setParams({
                "departure": departure,
                "arrival" :arrival
            });
            action.setCallback(this, response => {

                //If there's an error in the Apex class it's displayed as a Toast
                if (response.getState() === 'ERROR') {
                  
                    var errorMsg = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errorMsg[0].message
                    });
                    toastEvent.fire();

                }

                //If everything ok fills var from cmp
                else if (response.getState() === 'SUCCESS') { 
                    
                    component.set("v.flight", response.getReturnValue());
                    // component.set("v.created", true);
                    
                 }
            });
            $A.enqueueAction(action);
        }
        
    }
})
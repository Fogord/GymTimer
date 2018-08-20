/**
  * Class of creating custom qml component.
  **/
var createPage = (function  () {
    // The array of elements for placed items from top to bottom at parent
    var arrayOfParents = [];
    // The saved element who provide observer algorithm
    var observer;

    // The array which contains dynamic created items
    var componentCreated = [];

    // Available items
    var componentList = [
                "StackView",
                "Header",
                "Item",
                "Flow",
                "Row",
                "Column",
                "Label",
                "Button",
                "Line",
                "Input",
                "List",
                "Popup",
                "PopupEditText",
                "PopupEditTime",
                "Timer",
                "Clock",
                "Bluetooth"
            ];

    // The function for creating items from componentList and pushing those in componentCreated
    var createAllComponents = (function () {
        for(var i = 0; i < componentList.length; i++) {
            componentCreated[componentList[i]] = Qt.createComponent("../qml/components/Component" + componentList[i] + ".qml");

            if(componentCreated[componentList[i]].status !== 1 ) {
                console.log("Status:", componentCreated[componentList[i]].status);
                while(componentCreated[componentList[i]].progress !== 1) {
                    console.log("Progress:", componentCreated[componentList[i]].progress);
                }

                if(componentCreated[componentList[i]].status === 3 ) {
                    console.log("Error:"+  componentCreated[componentList[i]].errorString(), componentList[i]);
                    throw "Error created";
                }
            }
        }
    })()

    // Adding elements and default anchorsing
    var addElements = function (arrayOfElements, parentElement) {
        var priviosElement, anchorsTopElement, anchorsBottomElement;

//        if(!arrayOfElements["componentName"])
//            throw"You have to create elements with property \"componentName\"";

        var newChildObject = createElements(arrayOfElements["componentName"], arrayOfElements["property"] || {}, parentElement);

        bindingPublish(newChildObject, arrayOfElements["publish"]);
        bindingSubscribe(newChildObject, arrayOfElements["subscribe"]);

        fillModel(newChildObject, arrayOfElements["model"]);

        Object.defineProperty(newChildObject, "observer", { //for get observer from anywhere
                                  enumerable: false,
                                  configurable: false,
                                  writable: false,
                                  value: observer
                              })

        if(!newChildObject.free) {
            if(newChildObject.objectName !== "Popup" && newChildObject.objectName !== "PopupEditText" && newChildObject.objectName !== "PopupEditTime" &&newChildObject.objectName !== "Timer" && newChildObject.parent.objectName !== "Row" ){
                if (arrayOfParents.length > 0){
                    priviosElement = arrayOfParents[arrayOfParents.length - 1];
                    anchorsTopElement = priviosElement.bottom;
                } else {
                    anchorsTopElement = parentElement.top;
                }

                newChildObject.anchors.top = anchorsTopElement
            }
        }

        if(arrayOfElements["elements"] && arrayOfElements["elements"].length !== 0) {
            arrayOfParents = [];
            for (var key in arrayOfElements["elements"]) {
                if(arrayOfElements["elements"].hasOwnProperty(key)) {
                    addElements(arrayOfElements["elements"][key], newChildObject);
                }
            }
        }

        if(newChildObject.parent.objectName == "StackView") {
            newChildObject.parent.push(newChildObject)
        }

        arrayOfParents.push( newChildObject );
    }

    // Creating elements and fill property
    var createElements = function (componentName, properties, parentElement){
        var newObject;

        newObject = componentCreated[componentName].createObject(parentElement);
        if (newObject === null){
            throw (componentName + " isn`t created");
        }

        fillElemetProperty(newObject, properties);

        newObject.objectName = componentName;
        return newObject;
    }

    // The function-callback for connected signal from qml
    var publishCalback = function(connectionObj){
        connectionObj.publishContext[connectionObj.keyConnection].connect(
            function(){ observer.algorithm.publish(connectionObj.publisherType, connectionObj.publishContext); }
        );
    }

    // The function for binding (connect) qml default signals and user signals for publish some actions
    // publish: {
    //  clicked: "theBtnIsClicked" // qml signal: "publishType"
    // }
    var bindingPublish = function(object, publish) {
        if (publish && object) {
            for (var key in publish) {
                if(publish.hasOwnProperty(key)) {
                    try {
                        publishCalback({ keyConnection:key, publisherType: publish[key], publishContext: object});
                    }
                    catch (err) {
                        throw "Error binding publish " + JSON.stringify(err) + " " + err
                    }
                }
            }
        }
    }

    // The function for binding callbacks and call someone after calling publish function whith publishType
    // subscribe: {
    //  theBtnIsClicked: function(){} // publishType: callback
    // }
    var bindingSubscribe = function(object, subscribe) {
        if (subscribe && object) {
            for (var key in subscribe) {
                if(subscribe.hasOwnProperty(key)) {
                    try {
                        observer.algorithm.subscribe(key, subscribe[key], object);
                    }
                    catch (err) {
                        throw "Error binding subscribe"
                    }
                }
            }
        }
    }

    // The function for filing elements of user model to model of listView
    var fillModel = function(component, model){
        if (component && model) {
            try {
                component.model.clear();
                for (var key in model) {
                    component.model.append(model[key]);
                }
            }
            catch (err) {
                throw "Error to add model " + JSON.stringify(err);
            }
        }
    }

    // Filing property and calculating height by percent value
    var fillElemetProperty = function (object, properties) {
        if (properties && object) {
            for (var key in properties) {
                if(properties.hasOwnProperty(key)) {
                    try {
                        if(key === 'heightPercent'){
                            object["height"] = object.parent.height * properties[key];
                        }

                        object[key] = properties[key];


                    }
                    catch (err) {
                        fillElemetProperty(object[key], properties[key]);
                    }
                }
            }            
        }
    }

//    ///////////////////////////     ////    ///////////////////////////     //

    // function for add elements to parent
    return function (structOfQml, parentElement) {
        // checking  that array of qml obj is set
        if(!structOfQml)
            throw "Need to set array of structur qml"

        // checking that parent is set
        if(!parentElement)
            throw "Need to set parent"

        if(!observer)
            observer = parentElement;

        arrayOfParents = [];

        for(var i = 0; i < structOfQml.length; i++){
            addElements(structOfQml[i], parentElement);
        }
    }
})();

//========================== observer ================================//

var publisher = {
    // The arrayy of all posible action
    subscribers: {
        any: []
    },
    // The function that help to subscribe callback to publishe by publisheType
    subscribe: function (type, fn, context) {
        type = type || 'any';
        fn = typeof fn === "function" ? fn : context[fn];
        if (typeof this.subscribers[type] === "undefined") {
            this.subscribers[type] = [];
        }

        this.subscribers[type].push({fn: fn, context: context || this});

        for(var key in this.subscribers[type]) {
            if (this.subscribers[type][key].context === null) {
                this.subscribers[type].splice(key, 1);
            }
        }
    },
    // The function that help to usubscribe callback from publishe by publisheType
    unsubscribe: function (type, fn, context) {
        this.visitSubscribers('unsubscribe', type, fn, context);
    },
    // The function that help to publish callback with some publisheType
    publish: function (type, publication) {
        this.visitSubscribers('publish', type, publication);
    },
    // The function contein all logic of algorithm observer
    visitSubscribers: function (action, type, fn, context) {
        var subscribers = this.subscribers[type];
            type        = type || 'any';
        try {
            for (var i = 0; i < this.subscribers[type].length; i ++) {
                if (action === "publish") {
                    subscribers[i].fn.call(subscribers[i].context, fn);
                } else {
                    if (subscribers[i].fn === fn && subscribers[i].context === context) {
                        subscribers[i].fn = function(){}
                        subscribers[i].context = null;
                    }
                }
            }
        } catch (err) {
            console.log(err, err.fileName + ": " + err.lineNumber)
        }
    }
};

// Method that provide algorithm observer
function makePublisher(o) {
    var i;
    for (i in publisher) {
        if (publisher.hasOwnProperty(i) && typeof publisher[i] === "function") {
            o.algorithm[i] = publisher[i];
        }
    }
    o.algorithm.subscribers = {any: []};
}


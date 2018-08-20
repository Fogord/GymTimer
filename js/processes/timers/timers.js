var timers = (function (){

    var parentHeight;

    //intervals
    var prestartInterval = 0;
    var doInterval = 0;
    var relaxInterval = 0;
    var FIRSTPAGE = 1

    var currenrTimerSettings = {};
    var currentModel = null;
    // The index of manipulated  item of model
    var currentIndexItemList;
    var currentTimerName;
    // The temporary  array of filtered model items
    var filteredModel = [];

    // common header item
    // show information about apps
    // stack managing
    var headerOfStackView =  {
        componentName: "Header",
        property: {
            heightPercent: 0.1,
            visibleAddBtn: false,
            visibleBackBtn: false,
            text: "Timers"
        },
        publish: {
            pressedBack: "stackPop",
            showPopupItem: "showPopupItem",
        },
        subscribe:  {
            // signal from stack to maneging stackpop button
            stackDepthChanged: function(publisher) {
                if(publisher.depth !== FIRSTPAGE) {
                    this.text = currentTimerName;
                    this.visibleBackBtn = true;
                } else {
                    this.text = headerOfStackView.property.text;
                    this.visibleBackBtn = false;
                }
            }
        }
    }

    // show information about app
    var popupItem = {
        componentName: "Popup",
        property: {
            pading: 10,
            popupText: "<br>" + "Created by: <i>Artem Yerko</i>" + "<br>" + "Date: 16.08.2018" + "<br>" + "Version: 2.2" + "<br>"
        },
        publish: {
            closed: "closedPopup"
        },
        subscribe: {
            // signal from header to show this item
            showPopupItem: function(publisher) {
                this.open();
            }
        }
    }

    // window of timer item
    var timerItemDeteils = function() {
        // list of choosen timer
        var list = {
            componentName: "List",
            property: {
                clip: true,
                heightPercent: 0.43,
                margin: 4,
                iconRemoveSource: "qrc:./img/delete.png",
                iconChangeSource: "qrc:./img/edit.png",
                borderColor: "#808080",
                currentModelId: null,
            },
            publish: {
                itemRemove:   "timeItemRemove",
                itemChanging: "timeItemChanging",
                changeMutedStatus: "changeMutedStatus"
            },
            subscribe: {
                // signal from poup for add new time for current timer
                timerItemInserted: function(publisher){
                    if( publisher.newItem.textInput) {
                        var newItem = {
                            timersId: currentIndexItemList,
                            name    : publisher.newItem.textInput,
                            color   : publisher.newItem.color,
                            colorId : publisher.newItem.colorId,
                            seconds : publisher.newItem.seconds,
                            muted   : +publisher.newItem.muted
                        }
                        var rowInsertedId = localStorage.dbInsert({ tableName: "timerElements",        parametrs:newItem}) //insert DB
                        this.model.append(newItem)
                    }
                },
                // signal from time item for deleting
                timeItemRemove: function(publisher){
                    // all manipulation by current model
                    var modelItem = this.model.get(this.currentIndex);
                    localStorage.dbDeleteRow({ tableName: "timerElements",        where: {elementsId: modelItem.elementsId, timersId: modelItem.timersId}});//delete DB
                    this.model.remove(this.currentIndex);
                },
                // signal from poup for changing time for current timer
                timeItemChanged: function(publisher){
                    // all manipulation by current model
                     var modelItem = this.model.get(this.currentIndex);
                    if( publisher.newItem.textInput) {
                        var changedItem = {
                            timersId: currentIndexItemList,
                            name    : publisher.newItem.textInput,
                            color   : publisher.newItem.color,
                            colorId : publisher.newItem.colorId,
                            seconds : publisher.newItem.seconds,
                            muted   : +publisher.newItem.muted
                        }
                        localStorage.dbUpdate({ tableName: "timerElements", parametrs:changedItem, where: {elementsId: modelItem.elementsId, timersId: modelItem.timersId}});
                        this.model.set( this.currentIndex, changedItem);
                    }
                },
                // signal from time item forchanging mute status of it
                changeMutedStatus: function(publisher){
                    var modelItem = this.model.get(this.currentIndex);
                    var muted = !modelItem.muted;
                    localStorage.dbUpdate({ tableName: "timerElements", parametrs:{muted: +muted}, where: {elementsId: modelItem.elementsId, timersId: modelItem.timersId}});
                    this.model.get(this.currentIndex).muted = +muted;
                },
                // signal stack for refrash model
                stackDepthChanged: function(publisher){
                    this.model.clear()
                    this.model.append(currentModel)
                    list.property.currentModelId = this.model;
                },
                // cleaned publishers and subscribers
                stackPop: function (publisher) {
                    for(var key in list.subscribe) {
                        publisher.observer.algorithm.unsubscribe(key, list.subscribe[key], this)
                    }
                }
            }
        }
        // the item for change values or add new item
        var popupEditTime = {
            componentName: "PopupEditTime",
            property: {
            },
            publish: {
                closed:            "closedPopup",
                timeInputAccepted: "timerItemInserted",
                timeEditAccepted:  "timeItemChanged"
            },
            subscribe: {
                // signal for close this item
                timerItemInserted: function() {
                    this.close();
                },
                // signal for close this item
                timeItemChanged: function() {
                    this.close();
                },
                // signal to init values of edit item before show item
                timeItemChanging: function(publisher) {
                    var modelItem = publisher.model.get(publisher.currentIndex);

                    this.open()
                    this.isEditItem = true;
                    this.textInput = modelItem.name;
                    this.time = modelItem.seconds;
                    this.choosenColorName = modelItem.color;
                    this.choosenColorId = modelItem.colorId;
                    this.soundIsMuted = modelItem.muted;
                },
                // signal to init item before show item
                showPopupEditTime: function(publisher) {
                    this.isEditItem = false;
                    this.time = 0
                    this.choosenColorId = 0
                    this.open();
                },
                // delete signal when stack change
                stackPop: function (publisher) {
                    for(var key in popupEditTime.subscribe) {
                        publisher.observer.algorithm.unsubscribe(key, popupEditTime.subscribe[key], this)
                    }
                }
            }
        }
        // the button for emit signal to show popupEditTime
        var addItemToListTime = {
            componentName: "Button",
            property: {
                anchorsRight: true,
                anchorsRightMargin: 10,
                anchorsBottom: true,
                anchorsBottomMargin: 10,
                free: true,
                text: "+",
                z: 1
            },
            publish: {
                clicked: "showPopupEditTime",
            },
            subscribe: {
                // delete signal when stack change in oure case it`s popping stack
                stackPop: function (publisher) {
                    for(var key in addItemToListTime.subscribe) {
                        publisher.observer.algorithm.unsubscribe(key, addItemToListTime.subscribe[key], this)
                    }
                }
            }
        }
        // the item who playing all items of chossen timer
        var clock = {
            componentName: "Clock",
            property: {
                width           : 200,
                height          : 220,
                repeaterValue   : currenrTimerSettings[0].repeater,
                repeaterValueMax: 10,
                infinityChecked : currenrTimerSettings[0].infinity,
                currentTimer    : 0,
                countedTime     : 1
            },
            publish: {
                timeChanged     : "timeChanged",
                palyClicked     : "play",
                pauseClicked    : "pause",
                stopClicked     : "stop",
                repaterClicked  : "repater",
                infinityClicked : "infinity"
            },
            subscribe: {
                // signal from item when temer was trigerd
                timeChanged: function(publisher){
                    var iTimer = clock.property.currentTimer;

                    this.secondsNow++; // the one seconds passed

                    if (this.secondsNow === clock.property.countedTime + currentModel[iTimer].seconds) {
                        iTimer++;
                        clock.property.countedTime = this.secondsNow;

                        if(iTimer === currentModel.length) {
                            if(this.infinityChecked || this.repeaterValue !== 0){
                                this.repeaterChecked = false;
                                this.repeaterChecked = true;
                                if (!this.infinityChecked) {
                                    --this.repeaterValue;
                                }
                                iTimer = 0;
                            }
                            if(this.repeaterValue === 0) {
                                clock.subscribe.stop(this);
                                return;
                            }
                        }

                        this.startLight = false;
                        this.toColor = currentModel[iTimer].color;
                        this.startLight = true;
                        this.sound = currentModel[iTimer].muted?"":"qrc:/sound/goX2.wav"
                    }

                    clock.property.currentTimer = iTimer;
                },
                // signal from this item when was pressed start button
                play: function(publisher){
                    if(currentModel.length) {
                        this.playVisible          = false;
                        this.pauseVisible         = true;
                        this.sound                = currentModel[0].muted?"":"qrc:/sound/goX2.wav"
                        this.startLight           = false;
                        this.toColor              = currentModel[0].color;
                        this.startTimer           = this.startLight = true;
                    }
                },
                // signal from this item when was pressed pause button
                pause: function(publisher){
                    this.playVisible    = true;
                    this.pauseVisible   = false;
                    this.startTimer     = this.startLight = false;
                },
                // signal from this item when was pressed stop button
                stop: function(publisher){
                    publisher.playVisible          = true;
                    publisher.pauseVisible         = false;
                    publisher.startTimer           = publisher.startLight = false;
                    publisher.secondsNow           = clock.property.currentTimer = 0;
                    publisher.fromColor            = "#FFFFFF";
                    publisher.toColor              = "#FFFFFF";
                    publisher.repeaterValue        = currenrTimerSettings[0].repeater;
                    publisher.infinityChecked      = currenrTimerSettings[0].infinity;
                    publisher.isNeedToPlay         = false;
                    clock.property.countedTime     = 1;
                },
                // signal from this item when was pressed repater button
                repater: function(publisher){
                    this.repeaterChecked = true;
                    this.infinityChecked = false;
                    if(this.repeaterValueMax === this.repeaterValue) {
                        currenrTimerSettings[0].repeater = this.repeaterValue = 1
                    } else {
                        currenrTimerSettings[0].repeater = ++this.repeaterValue }
                    localStorage.dbUpdate({ tableName: "timerSettings", parametrs:{ repeater: this.repeaterValue, infinity: 0 }, where: {timersId: currentIndexItemList}});
                },
                // signal from this item when was pressed infinity button
                infinity: function(publisher){
                    this.repeaterChecked = !this.infinityChecked;
                    currenrTimerSettings[0].infinity = this.repeaterChecked;
                    localStorage.dbUpdate({ tableName: "timerSettings", parametrs:{ repeater: this.repeaterValue, infinity: +this.repeaterChecked }, where: {timersId: currentIndexItemList}});
                },
                // delete signal when stack change in oure case it`s poping stack
                stackPop: function (publisher) {
                    clock.subscribe.stop(this);
                    for(var key in clock.subscribe) {
                        publisher.observer.algorithm.unsubscribe(key, clock.subscribe[key], this)
                    }
                }
            }
        }
        // Main element container of
        var item = [{
                        componentName: "Item",
                        elements: [ addItemToListTime, popupEditTime, clock, list ]
                   }]

        return item;
    }

    // window of timers list
    var timerList = function() {
        // list of timers
        var list = {
            componentName: "List",
            property: {
                clip: true,
                heightPercent: 0.87,
                margin: 4,
                iconRemoveSource: "qrc:./img/delete.png",
                iconChangeSource: "qrc:./img/edit.png",
                borderColor: "#808080",
                currentModelId: null
            },
            publish: {
                itemRemove:   "itemRemove",
                itemChanging: "itemChanging",
                itemDeteils:  "itemDeteils"
            },
            subscribe: {
                itemInserted: function(publisher){
                    if(publisher.textInput) {
                        if (list.property.currentModelId == this.model) { //// сохранил id для определения с какой моделью работаю
                            var rowInsertedId = localStorage.dbInsert({ tableName: "timers",        parametrs:{ name: publisher.textInput}})
                                                localStorage.dbInsert({ tableName: "timerSettings", parametrs:{ timersId: rowInsertedId, repeater: 1, infinity: 0 }})

                            this.model.append({name: publisher.textInput, elements: [], timersId: rowInsertedId, timerSettings: {repeater: 1, infinity: false }});
                        }
                    }
                },
                itemRemove: function(publisher){
                    var modelItem = this.model.get(this.currentIndex);
                    localStorage.dbDeleteRow({ tableName: "timers",        where: {timersId: modelItem.timersId}});
                    localStorage.dbDeleteRow({ tableName: "timerSettings", where: {timersId: modelItem.timersId}});
                    localStorage.dbDeleteRow({ tableName: "timerElements", where: {timersId: modelItem.timersId}});
                    this.model.remove(this.currentIndex);
                },
                itemChanged: function(publisher){
                    var modelItem = this.model.get(this.currentIndex);
                    if(publisher.textInput) {
                        modelItem.name = publisher.textInput;
                        localStorage.dbUpdate({ tableName: "timers", parametrs:{name: publisher.textInput}, where: {timersId: modelItem.timersId}});
                    }
                },
                stackDepthChanged: function(publisher){
                    this.model.clear()
                    this.model.append(currentModel)
                    list.property.currentModelId = this.model;
                }
            }
        }
        // the item for change values or add new item
        var popupEditText = {
            componentName: "PopupEditText",
            property: {
                pading: 10,
                rightBtnText: "ok",
                placeholderTextInput: "Enter the name of new item",
            },
            publish: {
                closed:            "closedPopup",
                textInputAccepted: "itemInserted",
                textEditAccepted:  "itemChanged"
            },
            subscribe: {
                itemInserted: function() {
                    this.close();
                },
                itemChanged: function() {
                    this.close();
                },
                itemChanging: function(publisher) {
                    this.open()
                    this.isEditItem = true;
                    this.textInput = publisher.model.get(publisher.currentIndex).name;
                },
                itemChangingDeteils: function(publisher) {
                    this.open()
                    this.isEditItem = true;
                    this.textInput = publisher.model.get(publisher.currentIndex).name;
                },
                showPopupEditText: function(publisher) {
                    this.isEditItem = false;
                    this.open();
                }
            }
        }
        // the button for emit signal to show popupEditText
        var addItemToList = {
            componentName: "Button",
            property: {
                anchorsRight: true,
                anchorsRightMargin: 10,
                anchorsBottom: true,
                anchorsBottomMargin: 10,
                free: true,
                text: "+",
                z: 1
            },
            publish: {
                clicked: "showPopupEditText"
            },
            subscribe: {

            }
        }
        // Main element container
        // It has two subscribed action. This action publish pupup item.
        var item = [{
            componentName: "Item",
            elements: [
                popupItem,
                headerOfStackView,
                {componentName:"Line"},
                {componentName: "StackView",
                    elements: [{
                                    componentName: "Item",
                                    elements: [addItemToList, popupEditText, list]
                              }],
                    publish: {
                        depthChanged: "stackDepthChanged",
                    },
                    subscribe: {
                        stackPop:function() {
                            currentModel = localStorage.dbRead({ tableName: "timers"});
                            this.pop();
                        },
                        itemDeteils: function(publish){
                            var modelItem = publish.model.get(publish.currentIndex);

                            currentTimerName     = modelItem.name;
                            currentIndexItemList = modelItem.timersId;

                            currenrTimerSettings = localStorage.dbRead({ tableName: "timerSettings", where: {timersId: currentIndexItemList} });
                            currentModel         = localStorage.dbRead({ tableName: "timerElements", where: {timersId: currentIndexItemList} });

                            createPage(timerItemDeteils(), this)
                        }
                    }
                }],
                subscribe: {
                    showPopupEditText: function(){
                        this.opacity = 0.2
                    },
                    itemChanging: function(){
                        this.opacity = 0.2
                    },
                    showPopupItem: function(){
                        this.opacity = 0.2
                    },
                    timeItemChanging: function(){
                        this.opacity = 0.2
                    },
                    showPopupEditTime: function(){
                        this.opacity = 0.2
                    },
                    closedPopup: function() {
                        this.opacity = 1.0
                    }
                }
        }];

        return item;
    }

    // the starting point
    var start = function(parent) {
        currentModel = localStorage.dbRead({ tableName: "timers"})
        createPage(timerList(), parent)
    }

    return{
        start: start
    }
})();

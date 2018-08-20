var lockerPage = {
    isCorrect: function(){}
}

page.lockerStart = function() {
    var objPage = [{
                    componentName: "Image",
                    source: "../img/logo.png"
                },{
                    componentName: "Label",
                    text: "Pleace sing in:",
                    color: "darkblue"
                },{
                    componentName: "SignIn",
                }];

    var objMenu = [{
                    name: "first"
                 },{
                    name: "second"
                 },{
                    name: "third"
                 }];

    engine.createPage({
        start:function (){
//            page.mainNews();
        },
        pageObj: objPage,
        menu: objMenu,
        menuLoader: {source: "menu"},
        loader: {
            loaderId : "lockerLoader",
            source   : "locker"
        },
        buttonCallback: function(login, password){
            console.log("login", login);
            console.log("password", password);
            mainWindow.isLogined = true;
            page.mainNews();
        },
        finish: function(){
            page.mainNews();
        }
    });
}

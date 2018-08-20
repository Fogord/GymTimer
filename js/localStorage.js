var localStorage = (function() {
    var tables= [{
                     name: "timers",
                     column: [{name:"name",     type:"TEXT"},
                              {name:"timersId", type:"INTEGER",  primaryKey: true}]
                 },{
                     name: "timerElements",
                     column: [{name:"elementsId", type:"INTEGER", primaryKey: true},
                              {name:"timersId",   type:"INTEGER"},
                              {name:"name",       type:"TEXT"},
                              {name:"seconds",    type:"REAL"},
                              {name:"color",      type:"TEXT"},
                              {name:"colorId",    type:"INTEGER"},
                              {name:"muted",      type:"INTEGER"}]
                 },{
                     name: "timerSettings",
                     column: [{name:"timersId", type:"INTEGER"},
                              {name:"repeater", type:"INTEGER"},
                              {name:"infinity", type:"INTEGER"}]
                 }]

    function dbInit() {
        var db = LocalStorage.openDatabaseSync("Timers_DB", "1.0", "Exec", 1000000)
        try {
            db.transaction(function (tx) {
                var parametrs = [];
                for(var i = 0; i < tables.length; i++) {
                    parametrs = [];
                    for(var j = 0; j < tables[i].column.length; j++) {
                        parametrs.push(tables[i].column[j].name + ' ' + tables[i].column[j].type + ' ' + (tables[i].column[j].primaryKey?"PRIMARY KEY":""))
                    }
                    tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tables[i].name + ' ( ' + parametrs.join(', ') + ' )')
                }
            })
        } catch (err) {
            console.log("Error creating table in database: " + err)
        };
    }

    function dbGetHandle() {
        try {
            var db = LocalStorage.openDatabaseSync("Timers_DB", "", "Track exercise", 1000000)
        } catch (err) {
            console.log("Error opening database: " + err)
        }
        return db
    }

    var getClumnsValues = function(object) {
        var values = [];
        var columns = [];

        for (var key in object) {
            if(object.hasOwnProperty(key)) {
                columns.push('\"' + key + '\"');
                values.push('\"' + object[key] + '\"');
            }
        }

        return {
            columns: columns.join(', '),
            values:  values.join(', ')
        }
    }

    function stringifyConditions(stringifyObject, strUnion){
        var start, end;

        if(stringifyObject.constructor.name === "Array") {
            start = "["; end = "]";
        }
        if(stringifyObject.constructor.name === "Object") {
            start = "{"; end = "}";
        }

        var returnObj = '' + JSON.stringify(stringifyObject).replace(start, '').replace(end, '').replace(/,/g, strUnion).replace(/:/g, ' = ');
        return returnObj;
    }

    function dbInsert(insertedObject) {
        var rowid = 0;
        var parametrs;
        var tableName = insertedObject.tableName;

        db.transaction(function (tx) {
            if(insertedObject.tableName && insertedObject.parametrs) {
                parametrs = getClumnsValues(insertedObject.parametrs);
                tx.executeSql('INSERT INTO ' + insertedObject.tableName + ' ( '+ parametrs.columns +' ) ' + 'VALUES ( ' + parametrs.values + ' )');
            }
            rowid = tx.executeSql('SELECT last_insert_rowid()').insertId;
        });
        return rowid;
    }

    function dbRead(readObj) {
        var resultObj = [];
        db.transaction(function (tx) {
            var columns = '*';
            var where = ''
            var columnOfTable = [];
            var columnObject  = {};

            if(readObj.where){
                where = ' WHERE ' + stringifyConditions(readObj.where, ' and ');
            }

            for(var i = 0; i < tables.length; i++) {
                if(tables[i].name === readObj.tableName) {
                    for(var j = 0; j < tables[i].column.length; j++) {
                        columnOfTable.push(tables[i].column[j].name)
                    }
                    columns = columnOfTable.join(', ')
                    break;
                }
            }

            var results = tx.executeSql('SELECT ' + columns + ' FROM ' + readObj.tableName + where);

            for (var i = 0; i < results.rows.length; i++) {
                columnObject  = {};
                columnObject.id =  i + 1;
                for (var key in columnOfTable) {
                    if(columnOfTable.hasOwnProperty(key)) {
                        columnObject[columnOfTable[key]] = results.rows.item(i)[columnOfTable[key]];
                    }
                }
                resultObj.push(columnObject)
            }
        })
        return resultObj;
    }

    function dbDropTable(tableName) {
        db.transaction(function (tx) {
            if(tableName)
                tx.executeSql('DROP TABLE ' + tableName);
            else
                for(var i = 0; i < tables.length; i++) {
                    tx.executeSql('DROP TABLE ' + tables[i].name);
                }
        })
    }

    function dbUpdate(updateObj) {
        db.transaction(function (tx) {
            var parametrs = '';
            var where = ''

            if(updateObj.where){
                where = ' WHERE ' + stringifyConditions(updateObj.where, ' and ');
            }
            if(updateObj.parametrs){
                parametrs = stringifyConditions(updateObj.parametrs,  ', ');
            }

            tx.executeSql('UPDATE '+ updateObj.tableName + ' SET ' + parametrs + where)
        })
    }

    function dbDeleteRow(deleteObj) {
        db.transaction(function (tx) {
            var where = ''

            if(deleteObj.where){
                where = ' WHERE ' + stringifyConditions(deleteObj.where, ' and ');
            }

            tx.executeSql('DELETE FROM ' + deleteObj.tableName + where)
        })
    };

    var db = dbGetHandle()

    return {
        dbInit      : dbInit,
        dbInsert    : dbInsert,
        dbDropTable : dbDropTable,
        dbRead      : dbRead,
        dbUpdate    : dbUpdate,
        dbDeleteRow : dbDeleteRow
    }
})()

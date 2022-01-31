"use strict";



//----------------------------------------------------------------------------------------------------
//props just in case

if (typeof Array.isArray === "undefined") {
    Array.isArray = function (arg) {
        return Object.prototype.toString.call(arg) === "[object Array]";
    };
}






//----------------------------------------------------------------------------------------------------
//ALL services.....
var app = angular.module('MyApp', ['ngRoute', 'ui.bootstrap']);



//startup bootstrap
//----------------------------------------------------------------------------------------------------

app.run(function() {
    //some settings to be add......
});




//constants and strings
//----------------------------------------------------------------------------------------------------
var error_rest_message="ПОМИЛКА ЧИТАННЯ/ЗАПИСИ ДАНИХ З СЕРВЕРА! Перевантажте сторинку!";
var date_tr_error='Помилка у перетворенні дати!';
var summary_marks_list=['Поточна',      'Семестрова 1',  'Семестрова 2',  'Річна',   'ДПА'];
var mark_converter_datas=['',           '26-08-',        '28-08-',        '30-08-',  '31-08-'];








//-----------------------------------------------------------------------------------
//router for option page. router resolve REST loadings before leu us see the page

app.config(function ($routeProvider) {
    $routeProvider
        .when("/", {
            templateUrl: "./main.htm",
            controller: "selectCtrl",
            resolve: {
                'getFromRest': ['ERS', function(ERS) {
                    return    ERS.getWLRest();
                }]
            },
            resolveAs: 'getFromRest'
        })



        .when("/edit", {
            templateUrl: "./edit.htm",
            controller: 'selectCtrl',
            resolve: {
                'getFromRest': ['ERS', function(ERS) {
                    return ERS.getSLRest();
                }]
            },
            resolveAs: 'getFromRest'
        })


        .otherwise({
            templateUrl: "./wait.htm",
            controller: 'selectCtrl'
        });
});

//router for option page
//-----------------------------------------------------------------------------------



//data container and REST service
//-----------------------------------------------------------------------------------

app.service('ERS', ['$q', '$http', '$location', function($q, $http, $location) {
    var savedData1 = {};
    function set(id, data) {
        savedData1[id]=data;
    }

    function get(id) {
        if (!(id in savedData1)) return null;
        return savedData1[id];
    }

    function getWLRest() {
        var path=get("path")+'rest/prepod_get/'+get("name");
        return  $http.get(path)
            .then(function(response, status) {
                set('subjs_classes', response.data);
            }, function(response) {
                if ((response.status != 401) && (response.status != 406))
                alert(error_rest_message);
            });
    }

    function getSLRest() {
        var path=get("path")+'rest/prepod_get/'+get("name")+'/'+encodeURIComponent(get("selected_subj"));
        return  $http.get(path)
            .then(function(response) {
                set('works', response.data.works);
                set('topics', response.data.topics);
                set('general_info', response.data);
            }, function(response) {
                if ((response.status != 401) && (response.status != 406))
                alert(error_rest_message);
            });
    }

    function sendSLRest(callMe) {
        var data=get('general_info');
        if (!data) return alert(error_rest_message);
        data.works=get('works');
        data.topics=get('topics');
        var path=get("path")+'rest/prepod_set/'+get("name");

        var config = {headers : {'Content-Type': 'application/json;charset=utf-8;'}, responseType: "text"};

        return  $http.post(path, data, config)
            .then(function() {callMe();},
                function(response) {
                    if ((response.status != 401) && (response.status != 406))
                    alert(error_rest_message);
                });
    }

    //helper - get URL parts for navigation url
    function get_name_from_url(){
        var ppath=$location.absUrl();                     //take url
        var pppath=ppath.split('/');
        pppath.splice(pppath.length-2, pppath.length);    //del  last 2
        var path=[]; path.push(pppath[pppath.length-2]);
        path.push(pppath[pppath.length-1]);               //join last   2
        return path;                                      //get  [role, user]
    }




    //data coder for navigating to special summary pages
    function getData4MarkType(data, mark_type){
        var marklist=getMarkList();

        function get_mark_data(mark_type){
            return mark_converter_datas[marklist.indexOf(mark_type)];
        }
        function if_current_mark(mark_type) {
            return marklist.indexOf(mark_type) == 0;
        }
        function get_special_data(data, mark_type) {
            var datas = data.split('-');
            //check for validity
            if (datas.length < 3) return alert(date_tr_error);
            if (isNaN(datas[2])) return alert(date_tr_error);
            //if we are in month before september - we need a previous year
            if (datas[1]<9) datas[2]=datas[2]-1;
            return get_mark_data(mark_type) + datas[2];
        }

        if  (if_current_mark(mark_type)) return data;
        return get_special_data(data, mark_type);

    }

    //summury marks
    function getMarkList(){
        return summary_marks_list;
    }



    return {
        set: set,
        get: get,
        getWLRest: getWLRest,
        getSLRest: getSLRest,
        sendSLRest:sendSLRest,
        get_name_from_url:get_name_from_url,
        getData4MarkType:getData4MarkType,
        getMarkList:getMarkList
    }
}]);


//data container and REST service
//-----------------------------------------------------------------------------------





//configuration for rest - disabling chash+++++++++++++++++++++++++++++++

app.config(['$httpProvider', function($httpProvider) {
    if (!$httpProvider.defaults.headers.get) {
        $httpProvider.defaults.headers.common = {};
    }
    $httpProvider.defaults.headers.common["Cache-Control"] = "no-cache";
    $httpProvider.defaults.headers.common.Pragma = "no-cache";
    $httpProvider.defaults.headers.common["If-Modified-Since"] = 'Mon, 26 Jul 1997 05:00:00 GMT';


    //central handling of error code
    //sent bt the server
    var myTransFunction=function(data, headersGetter, status){
        if ((status==406) ||
            (status==401)) {alert(data); data={};}
        return data;
    };
    $httpProvider.defaults.transformResponse.unshift(myTransFunction);
}]);







//directives++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//the invented way to init rest data needed for page is this directive
app.directive('initRestpath', function($parse, ERS) {
    return {
        restrict: 'A',

        link: function($scope, element, attrs) {
            var path=attrs.initRestpath;
            var name=attrs.initName;
            ERS.set("path", path);
            ERS.set("name", name);
        }
    }
});




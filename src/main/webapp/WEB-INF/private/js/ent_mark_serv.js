"use strict";



//----------------------------------------------------------------------------------------------------
//props just in case

if (typeof Array.isArray === "undefined") {
    Array.isArray = function (arg) {
        return Object.prototype.toString.call(arg) === "[object Array]";
    };
}



//constants and strings
//----------------------------------------------------------------------------------------------------
var error_rest_message="ПОМИЛКА ЧИТАННЯ/ЗАПИСИ ДАНИХ З СЕРВЕРА! Перевантажте сторинку!";
var date_tr_error='Помилка у перетворенні дати!';
var summary_marks_list=['Тематична','Семестрова 1', 'Семестрова 2', 'Річна', 'ДПА'];




var app = angular.module('myApp', ['smart-table', 'ui.bootstrap']);


//services
//---------------------------------------------------------------

app.factory('RS', ['$http', '$location',
    function($http, $location) {
        return {
            //call rest-server
            get_works_topics_list: function (path, prepod, subj, callMe) {
                var path=path+'rest/prepod_get/'+prepod+'/'+encodeURIComponent(subj);
                $http.get(path)
                    .then(function(response) {
                        callMe(response.data);
                    }, function(response) {
                        console.log(response.status);
                        if ((response.status != 401) &&(response.status != 406))
                            alert(error_rest_message);
                    });
            },

            //call rest-server
            set_marks_list: function (path, prepod, subj, form, date, info, callMe) {
                var path=path+'rest/journal_set/'+prepod+'/'+encodeURIComponent(form)
                    +'/'+encodeURIComponent(subj)+'/'+encodeURIComponent(date);

                var config = {headers : {'Content-Type': 'application/json;charset=utf-8;', 'Accept-Charset': 'utf-8'}};

                return  $http.post(path, JSON.stringify(info), config)
                    .then(function(response) {
                        callMe(response.data);
                    }, function(response) {
                        console.log(response.status);
                        if ((response.status != 401) && (response.status != 406))
                            alert(error_rest_message);
                    });
            },


            //call rest-server
            get_marks_list: function (path, prepod, subj, form, date, callMe) {
                var path=path+'rest/journal_get/'+prepod+'/'+form+'/'+subj+'/'+date;

                $http.get(path)
               .then(function(response) {
                        callMe(response.data);
                    }, function(response) {
                        console.log(response.status);
                        if ((response.status != 401) &&(response.status != 406))
                            alert(error_rest_message);
                    });
            },


            //extract parts from url string
            get_name_from_URL: function(){
                var ppath=$location.absUrl();                     //take url
                var pppath=ppath.split('/');
                pppath.splice(pppath.length-2, pppath.length);    //del  last 2
                var path=[]; path.push(pppath[pppath.length-2]);
                path.push(pppath[pppath.length-1]);               //join last   2
                return path;                                      //get  [role, user]
            },


            //excluding last part of subject name - usually looks as "9кл"
            exclude_last_word: function(subj_st){
                if (subj_st) {
                    var subj = subj_st.split(/[\s]+/);
                    if ((subj.length) > 1) {
                        subj.splice(subj.length - 1, subj.length);
                        subj = subj.join(" ");
                    }
                    subj=""+subj;
                    subj = subj.trim();
                }
                return subj;
            },

            //check if we are dealing with year summary date
            if_year_sunmmary: function(date){
                var list=[26,27,28,29,30,31];
                var dates = date.split('-');
                if (dates.length < 3) return alert(date_tr_error);
                if (isNaN(dates[1])) return alert(date_tr_error);
                if (isNaN(dates[0])) return alert(date_tr_error);
                var mnth=1*dates[1];
                var day=1*dates[0];
                if (mnth==8) if (list.indexOf(day)>=0) return true;
                return false;
            },

            //get a title for summury marks
            get_year_summary_name:  function(date){
                var dates = date.split('-');
                if (dates.length < 3) return alert(date_tr_error);
                if (isNaN(dates[0])) return alert(date_tr_error);
                var num_d=dates[0]*1;
                switch (num_d) {
                    case 26 : return 'Семестрова 1';
                    //case 27 : return 'Семестрова(к) 1';
                    case 28 : return 'Семестрова 2';
                    //case 29 : return 'Семестрова(к) 2';
                    case 30 : return 'Річна';
                    case 31 : return 'ДПА';
                    default: return null;
                }
            },

            get_summary_year: function(date){
                var dates = date.split('-');
                if (dates.length < 3) return alert(date_tr_error);
                if (isNaN(dates[2])) return alert(date_tr_error);
                return dates[2]*1;
            },

            //summury marks
            getMarkList: function (){return summary_marks_list;}

        };
    }
]);




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
            (status==401)) {console.log(data.toString()); alert(data); data={};}
        return data;
    };
    $httpProvider.defaults.transformResponse.unshift(myTransFunction);
}]);



//directives++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//the invented way to init rest data needed for page is this directive
app.directive('initRestpath', function($parse) {
    return {
        restrict: 'A',

        link: function($scope, element, attrs) {
            var expressionMetod = $parse(attrs.callonRest);
            $scope.path=attrs.initRestpath;
            $scope.name=attrs.initName;
            //super trick to execute function mentioned in directive with params
            expressionMetod($scope, {'path':$scope.path, 'name':$scope.name});
        }
    }
});


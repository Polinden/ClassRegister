"use strict";


//----------------------------------------------------------------------------------------------------
//props just in case

if (typeof Array.isArray === "undefined") {
    Array.isArray = function (arg) {
        return Object.prototype.toString.call(arg) === "[object Array]";
    };
}




//constants and strings
var works_resume='Тематична';
var year_summary='Підсумкові оцінки';
var toppic_bottom_string='Оцінка за тему';
var bottom_string='Середня оцінка';
var year_bottom_string='Підсумки семестрів і навчального року';
var topic_string='Тема:';
var no_marks='Немає оцінок';
var server_error="ПОМИЛКА ЧИТАННЯ ДАНИХ З СЕРВЕРА! Треба перевантажити сторинку!";
var data_error="Обшібка в форматі дати";





var app = angular.module('myApp', ['smart-table', 'ui.bootstrap']);


//services
//---------------------------------------------------------------

app.factory('RS', ['$http', '$location', '$rootScope',
    function($http, $location, $rootScope) {

        //find if we have come from prepod page
        var query=$location.search();
        var subject_fromURL=query['subj'];
        var is_a_student=(subject_fromURL)?false:true;


        //preparing the model to display
        //most important function to make data a nice look
        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        var prepare_and_sort_data=function (data) {

                var newdata=[];
                var listdata=[];

                if ((!data) || (!Array.isArray(data))) return null;


                //create an array of empty objects: one object for each topic, object contans table, title, summary
                //then putt this ampty object to array of topics and tables - newdata
                data.forEach(function(x) {
                    //create a uniq object for every topic
                    if (listdata.indexOf(x.topic) < 0) {
                        //make unique
                        listdata.push(x.topic);
                        //create empty object first
                        var axdata = {};
                        axdata.entries = [];
                        //set topic
                        axdata.topic = x.topic;
                        //set title
                        axdata.toppic_string=topic_string;
                        //not empty topics are to put in array
                        //this array to be proceeded further
                        if (!(x.topic==null || x.topic=="")) newdata.push(axdata);
                    }
                });


                //fill objects with real data distributing accordingly to topics
                data.forEach(function(y) {
                    //enhance data - include 2 calendar years
                    function data_replace(data){
                        var datas=data.split('-');
                        if (data.length<3) return alert(data_error);
                        return datas[2]+'-'+(1*datas[2]+1);
                    }


                    if (listdata.indexOf(y.topic) >= 0) {
                        newdata.forEach(function(x) {
                            if (x.topic==y.topic) {
                                //delete data, if showing date is disabled
                                //show absence as "H"
                                //and delete erroniously putted lines withot mark
                                if (y.topic==year_summary) y.date=data_replace(y.date);
                                if (!y.show_date && is_a_student) y.date='';
                                if (!y.present) y.mark='Н';
                                if (!(y.mark==null || y.mark==0 || y.mark=='')) x.entries.push(y);
                            }
                        });
                    }
                });




                //find average, topic and summary marks and set up title and bottom
                newdata.forEach(function (z) {
                    var sum=0;
                    var count=0;
                    var topic_mark=0;
                    var topic_mark_position;

                    //for each line in table of marks
                   z.entries.forEach(function (k) {

                       //detect a topic summury mark amoung the lines
                       if (k.work==works_resume) {
                           topic_mark=k.mark;
                           topic_mark_position=z.entries.indexOf(k);
                       }
                           //for all other marks - not a topic symmary - to sum up for average
                           else if (!isNaN(k.mark) && (k.mark!=0)) {
                                sum+=k.mark;
                                count++;
                           }
                   });

                    //if topic summury was detected - put this summary instead of average
                    if (topic_mark>0) {
                        z.avermark=topic_mark;
                        //set summury string
                        z.bottom_string=toppic_bottom_string;
                        if (is_a_student) z.entries.splice(topic_mark_position, 1);
                    }
                        //if not - if there were eny mark counted - to calculate average
                        else if (count>0) {
                            //calculate average
                            sum=sum/count;
                            sum = Math.round (sum*10) / 10;
                            z.avermark=sum;
                            //set bottom string
                            z.bottom_string= bottom_string;
                        }
                               //if not - the average is null
                               // just write that there are no marks
                               else {
                                    //set bottom string
                                   z.bottom_string='';
                                   z.avermark=no_marks;
                               }

                    //for year summary case
                    if (z.topic==year_summary) {
                        //set bottom and title strings
                        z.bottom_string=year_bottom_string;
                        z.toppic_string='';
                        z.avermark='';
                    }
                });






                //sort - put year summary table to the last position
                var glass;
                var found_place=-1;
                newdata.forEach(function(q){
                    if (q.topic==year_summary) {
                        found_place=newdata.indexOf(q);
                        glass=q;
                    }
                });
                if(found_place>-1) {
                    newdata.splice(found_place, 1);
                    newdata.push(glass);
                }


                return newdata;
            };





        //rest functions
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        return {
            //rest API
            get_stud_name: function (restPath, student, callMe) {
                if ($rootScope.exiter) return;
                var path=restPath+'rest/studname/'+student;
                $http.get(path)

                    .then(function(response) {
                        callMe(response.data);
                    }, function(response) {
                        if ((response.status != 401) && (response.status != 406))
                        alert(server_error);
                    });
            },


            //rest API
            get_marks_list: function (host, student, subj, callMe) {
                if ($rootScope.exiter) return;
                var path=host+'rest/journal/'+student+'/'+subj;
                $http.get(path)

                    .then(function(response) {
                        callMe(prepare_and_sort_data(response.data));
                    }, function(response) {
                        if ((response.status != 401) && (response.status != 406))
                        alert(server_error);
                    });
            },

            //rest API
            get_subj_list: function (path, student, callMe) {
                if ($rootScope.exiter) return;
                path=path+'rest/worklist/'+student;
                $http.get(path)

                    .then(function(response) {
                        callMe(response.data);
                    }, function(response) {
                        if ((response.status != 401) && (response.status != 406))
                        alert(server_error);
                    });
            },

            //get parts from URL string for navigation
            get_name_from_URL: function(){
                var ppath=$location.absUrl();                     //take url
                var pppath=ppath.split('/');
                var path=[];
                path.push(pppath[pppath.length-3]);
                path.push(pppath[pppath.length-2]);               //join last  2
                if (path[0]=='stud') return path[1];
                return path[0];                                   //return  "student login"
            },

            //delete last word from subject name which expect to be like "9кл"
            exclude_last_word: function(subj_st){
                if (subj_st) {
                    var subj = subj_st.split(" ");
                    if ((subj.length) > 1) {
                        subj.splice(subj.length - 1, subj.length);
                        subj = subj.join(" ");
                    }
                    subj=""+subj;
                    subj = subj.trim();
                }
                return subj;
            }

    };}
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
            (status==401)) {alert(data); data={};}
        return data;
    };
    $httpProvider.defaults.transformResponse.unshift(myTransFunction);
}]);




//directives++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//the invented way to init rest data needed for page is this directive
app.directive('initRestpath', function($parse) {
    return {
        restrict: 'A',

        link: { post: function($scope, element, attrs) {
                    var expressionMetod = $parse(attrs.callonRest);
                    $scope.path = attrs.initRestpath;
                    $scope.name = attrs.initName;
                    //super trick to execute function mentioned in directive with params
                    expressionMetod($scope, {'path': $scope.path, 'name': $scope.name});
            }
        }
    }
});




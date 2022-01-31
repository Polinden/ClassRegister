"use strict";



//startup bootstrap
//----------------------------------------------------------------------------------------------------


app.run(function() {
    //some setups if needed......
});




//controllers
//----------------------------------------------------------------------------------------------------

app.controller('safeCtrl', ['$scope', '$location', 'RS', function ($scope, $location, RS) {


    //constants and globals
    var TABLCOLOR1="#DCDCDC";
    var TABLCOLOR2="#F5F5DC";
    //application path
    var root_path="";
    //visitor name
    var visitor_name="";
    //to prevent double start-up function to be launched
    var start_Notfirst=false;
    //subject if loaded in URL
    var query=$location.search();
    var start_subj=query['subj'];
    var prepod=query['prepod'];
    var form=query['class'];


    //styles
    $scope.mySt1 = {"background-color": TABLCOLOR1};
    $scope.mySt2 = {"background-color": TABLCOLOR2};








//on load document function run by a tag (see directive in the service file)!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $scope.startingUp=function(path, user_name){

        //prevent from  calling  2 times!
        if (start_Notfirst) return;  else start_Notfirst=true;
        //path - root of application, user_name - principal
        root_path=path; visitor_name=user_name;



        //MODEL!!!===========================
        $scope.subjects = [];
        $scope.original_subjects = [];
        $scope.subject_sel=null;
        //name of a student whose marks are observed
        $scope.studentName = RS.get_name_from_URL();
        //true means that a visitor is a prepod
        //it helps to change interface - hide button "back" if the page is entered by student
        $scope.if_a_prepod=(start_subj)?true:false;
        //!!!MODEL===========================




        //REST get ==========================
        //load marks  asyncroniously
        var loadMarks =function(subj){
            //load marks for it
            RS.get_marks_list(path, RS.get_name_from_URL(), subj, function(x){
                if (!x || !Array.isArray(x)) return null;
                $scope.rowCollection=x;
            });
        };

        //load marks  asyncroniously
        var setListSubj=function(){
            RS.get_subj_list(path, RS.get_name_from_URL(), function(x){
                if (!x || !Array.isArray(x)) return null;
                //delete alian subjects for a specific prepod - works only with prepods
                x=delExtraSubjects(x);
                //set original subject list
                $scope.original_subjects =x;
                //excluding the last word in subject names
                $scope.subjects=x.map(RS.exclude_last_word);
                if (start_subj!=null) var subj_cut=RS.exclude_last_word(start_subj);
                //set selected subject to title
                if ((subj_cut!=null) && $scope.subjects.indexOf(subj_cut)>=0)
                     $scope.subject_sel=$scope.subjects[$scope.subjects.indexOf(subj_cut)];
                else {
                    $scope.subject_sel = $scope.subjects[0];
                    start_subj = x[0];
                }
                //if sucsess - load Marks List
                adjust();   //adapt page size!
                loadMarks(start_subj);
            });

        };

        //enterring point - load student name async starting a chain - tge good idea to rewrute with promises
        RS.get_stud_name(path, $scope.studentName, function(x){
            if (!x) return null;
            $scope.studentName=x;
            //if sucsess - load Subject List
            setListSubj();
        });


        //on click imtes list listener for changing subject
        $scope.newSubj=function(subject){
            var index=$scope.subjects.indexOf(subject);
            var subj_uncat=$scope.original_subjects[index];
            $scope.subject_sel=subject;
            loadMarks(subj_uncat);
        };


        //REST get ==========================





        //helpers++++++++++++++++++++++++++++++++++++++++++++++++
        //helper not to hav error
        $scope.exiter=false;


        //nothing to do!!! only adapt size for a sertain list!
        var adjust=function(){
            var countHeith=countHeight();
            var height = countHeith;
            var w = window.innerWidth;
            if (w>768)angular.element(document.querySelector("body")).css("min-height", height+"em");
            else angular.element(document.querySelector("body")).css("min-height", 0+"em");
        };

        //count heght of left menu bar
        var countHeight=function(){
            var matr=$scope.subjects;
            if (matr ==null || !Array.isArray(matr) || matr.length==0) return 0;
            var count=0;
            matr.forEach(function (x) {if (x.length>48) count+=3; else if(x.length>17) count+=2; else count++;});
            count=count*1.9+14;
            return count;
        };

        //delete alian subjects from list
        var delExtraSubjects=function(x){
            if (!$scope.if_a_prepod) return x;
            if (!start_subj) return x;
            var y=[];
            y.push(start_subj);
            return y;
        }

    };

//on load document function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





//navigation
//------------------------------------------------------------------------------------


    $scope.doExit=function(){
        $scope.exiter=true;
        window.location=root_path+"goout";
    };


    $scope.doBack=function(){
        //if entered by student
        if (!$scope.if_a_prepod) $scope.doExit();
	    window.history.back();
    };



    //navigate to the edit page on pressing on date cell - avalible only for prepods
    $scope.goEdit=function(date){
        //if entered by student - do nothing
        if (!$scope.if_a_prepod) return;
        //if date is not parcable - do nothing
        if (!date) return;
        var check_date=date.split('-');
        if (check_date.length<3) return;
        var path = root_path + 'prepod/' + visitor_name + '/enter#?subj=' + start_subj + '&class='+form+'&date=' + date;
        window.location.replace(path);
    };

   
//navigation
//------------------------------------------------------------------------------------




}]);












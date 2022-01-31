"use strict";




//startup bootstrap  
//----------------------------------------------------------------------------------------------------


app.run(function() {
    //if you need some setups....
});


//controller tableCtrl
//----------------------------------------------------------------------------------------------------


app.controller('tableCtrl', ['$scope', 'RS', '$location', function ($scope, RS, $location) {

    
//settings and strings
    //strings
    var topic_mark='Тематична';
    var topicles='Оцінка без теми';
    var go_without_save="Вы дійсно виходите без збереження?";
    var summury_string='Підсумкові оцінки';
    var err_topic_message='Неприпустимо ставити тематичну оцінку і не вказувати тему!';
    var err_filling='Перевірте помилки в заповненні!';
    var success='Успішно збережено!';
    //settings
    var TABLCOLOR1="#DCDCDC";
    var TABLCOLOR2="#F5F5DC";
    var start_Notfirst=false;
    var query=$location.search();
    //query string parts
    var subj=query['subj'];
    var date=query['date'];
    var form=query['class'];
    //for form
    $scope.mySt1={"background-color": TABLCOLOR1};
    $scope.mySt2={"background-color": TABLCOLOR2};
    $scope.regex = "\\d+";



//on load document function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    $scope.startingUp=function(path, name){

        if (start_Notfirst) return;   //prevent from  calling  2 times!
        start_Notfirst=true;


       //MODEL!!!!!
        $scope.path = path;
        $scope.name=name;
        $scope.subjTitle="";
        $scope.classTitle="";
        $scope.dateTitle="";
        $scope.topics_list=[];
        $scope.works_list = [];
        $scope.tableModel = [{}];
        $scope.show_d = null;
        $scope.alerts=[];
        $scope.works_summary=[];
        $scope.classTitle=form;
        $scope.dateTitle=date;
        //getting subject parts from query inn URL(transfered by that mean by previous page)
        //excluding the last word in subject name
        $scope.subjTitle=RS.exclude_last_word(subj);
        $scope.if_year_summary=RS.if_year_sunmmary(date);
        $scope.year_summary_tile=RS.get_year_summary_name(date);
        $scope.summary_year=RS.get_summary_year(date)+'-'+(RS.get_summary_year(date)+1);
        $scope.works_summary.push(topic_mark);
        //!!!!MODEL



        //REST get information
        //get topics list
        RS.get_works_topics_list(path, name, subj, function (x) {
            //check and set lists
            if (x && x.topics && Array.isArray(x.topics)) {$scope.topics_list=x.topics;}
            if (x && x.works && Array.isArray(x.works)) {$scope.works_list =x.works;}
            //add universal item to the list and check it
            $scope.topics_list.push(topicles);

            //get marks list
            RS.get_marks_list(path, name, subj, form, date, function(x){
                //exclude errors
                if (x && Array.isArray(x)) {$scope.tableModel=x;}
                //ad absent topics or works get from model and put to list (if in model but not in list)
                helpifabsent($scope.works_list, x, "work");
                helpifabsent($scope.topics_list, x, "topic");
                //if journal list has a topic - to set a topic selected in drop down list
                if(x[0] && x[0].topic) $scope.selected_top=x[0].topic;
                //set show input-switch value "show date" according to the model
                $scope.show_d=$scope.get_show_date();
            });
        });

        //helper add if absent from y to --> x
        //to add topics and works if absent in general list
        function helpifabsent(matr1, matr2, name){
            if (!matr1 && !Array.isArray(matr1)) return;
            if (!matr2 && !Array.isArray(matr2)) return;
            var marklist=RS.getMarkList();
            matr2.forEach(function (y) {
                //if not empty
                if (y[name] && !/^\s*$/.test(y[name]))
                    //not in standart topic summary list
                    if (marklist.indexOf(y[name])<0) {
                        //not in drop down list already - to push!!
                        if (matr1.indexOf(y[name]) < 0) matr1.push(y[name]);
                    }
            })};

    };


//on load document function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





//handlers and functions of tableCtrl controller
    
    //copy toppic to every item
    $scope.copyworks_list = function (row) {
	var work=row.work;
        $scope.tableModel.forEach(function(x){if (x.present) x.work=work});
    };

    //copy remark to every item
    $scope.copyRemark = function (row) {
        var comment=row.comment;
        $scope.tableModel.forEach(function(x){x.comment=comment});
    };

    //set topics_list to all students
    $scope.settopics_list=function(){
        $scope.tableModel.forEach(function(x){x.topic=$scope.selected_top});
    };


    //get show date flag of all students
    $scope.get_show_date=function(){
        var result=true;
        if ($scope.tableModel==null || !Array.isArray($scope.tableModel)) return result;
        $scope.tableModel.forEach(function(x){result = (result && x.show_date)});
        return result;
    };

    //if student is absent to clear his fields
    $scope.doDissable = function (row) {
        var i=$scope.tableModel.indexOf(row);
        $scope.tableModel[i].mark=0;
        $scope.tableModel[i].topic="";
        $scope.tableModel[i].work="";
    };
    
    //listener for changing dirty status and prevent leaving page if dirty
    $scope.$watch('myForm.$dirty', function(newVal, oldVal){
        window.onbeforeunload=null;
        if ($scope. myForm.$dirty) window.onbeforeunload=saygoodbay;
    });

    //listener for changing "show date" switch
    $scope.$watch('show_d', function(newVal, oldVal){
        //if not initial state setting but a real choice happens
        if (oldVal!=null) $scope.tableModel.forEach(function(x){x.show_date=newVal});
    });

    $scope.close_alert=function(index){$scope.alerts.splice(index, 1);};

    
    //NAVIGATION==========================================================================

    //save data - sendRest
    $scope.doSend = function () {
        if ($scope.myForm.$invalid) return alert(err_filling);
        var query=$location.search();
        //in case we meet records without (with wrong) topic
        $scope.settopics_list();
        //check the form before sending and correct marks if needed!!!!!!!!
        var wrongtopic=false;
        $scope.tableModel.forEach(function(x){
            //for year summary page set specific work and topic
            if($scope.if_year_summary) {x.work=$scope.year_summary_tile; x.topic=summury_string}
            // if we are setting toppic mark then subject have to be set
            if ((x.work==topic_mark) && ($scope.selected_top==topicles)) wrongtopic=true;
            if (x.mark==null) x.mark=0;
            if (x.mark=="") x.mark=0;
            if (isNaN(x.mark)) x.mark=0;
            if (x.mark>12) x.mark=12;
            if (x.mark<0) x.mark=0;
        });
        if (wrongtopic) return alert(err_topic_message);
        //send to SERVER
        RS.set_marks_list($scope.path, $scope.name, subj, form, date,
            $scope.tableModel, function(x)  {
                if (x=="ok") {
                    $scope.myForm.$dirty=false;
                    $scope.alerts.push({msg: success});
                }
        });
    };


    //navigate to student data
    $scope.goName = function (name) {
	 if (($scope. myForm.$dirty) && (!confirm(go_without_save))) return;
        var path=$scope.path+'stud/'+name.login+'/show';
        path+='#/?subj='+encodeURIComponent(subj)+'&class='+encodeURIComponent(form)+'&prepod='+encodeURIComponent($scope.name);
        window.location = path;
    };

    
    //go back
    $scope.doBack = function () {
        if (($scope. myForm.$dirty) && (!confirm(go_without_save))) return;
        $scope. myForm.$dirty=false;
        var path=$scope.path+'prepod/'+$scope.name+'/select';
        window.location = path;
    };

    //go exit
    $scope.doExit = function () {
        if (($scope.myForm.$dirty) && (!confirm(go_without_save))) return;
        $scope. myForm.$dirty=false;
        window.location=$scope.path+"goout";
    };



}]); //controller





//little helper to confirm exit
var saygoodbay = function (event) {
  var message = 'Уходите не сохранив?';
  if (typeof event == 'undefined') {
    event = window.event;
  }
  if (event) {
    event.returnValue = message;
  }
  return message;
};

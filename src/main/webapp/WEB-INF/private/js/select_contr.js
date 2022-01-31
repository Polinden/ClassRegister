'use strict';





//----------------------------------------------------------------------------------------------------
//ALL controllers.....


//----------------------------------------------------------------------------------------------------
//!!!controller selectCtrl

app.controller('selectCtrl', ['$scope', '$rootScope', '$uibModal', '$location', 'ERS', '$route',
    function ($scope, $rootScope, $uibModal, $location, ERS, $route) {


        //addit to provide this service to DOM element
        $scope.myExservise=ERS;

        
        
        //MODEL!!!!!!!===============================================
        //LOAD AND PARSING ON LOADING ROUT PAGE!!!!===================================
        //this trick works only after the resolving of routs only!!!
        if ($route.current) {
            //getting router data - not neneed for promis - it is just examole of this option
            //$scope.forTest = $route.current.locals.getFromRest;


            //get loaded topics and works lists form ERS when controller in options-rout
            if (ifLoaded()) {  //exclusding errors
                var got_works=ERS.get('works');
                var got_topics= ERS.get('topics');
                //exclusding errors
                if (got_works && Array.isArray(got_works)) $scope.works = got_works;
                if (got_works && Array.isArray(got_works)) $scope.topics = got_topics;

                //get load subjects list form ERS when controller in main-rout
                if (!$scope.subjects) {
                    var subjects = [];
                    //populate subj list
                    var subjs_classes=ERS.get('subjs_classes');
                    //exclusding errors and...
                    if (subjs_classes && Array.isArray(subjs_classes)) {
                        //exclude subjects without classes (if prepod not complitly fill the database)
                        subjs_classes.forEach(function (x) {
                            if (x.classes.length>0) subjects.push(x.subject)});
                        }
                    //sort subjects and return
                    subjects.sort();
                    $scope.subjects = subjects;

                }


                //initialize lists and initially selected items if it was not done befort
                if (!ERS.get('selected_subj')) {
                    //exclusding errors
                    if($scope.subjects && Array.isArray($scope.subjects)) {
                        //excluding subjects without classes
                        ERS.set('selected_subj', $scope.subjects[0]);
                        ERS.set('classes', setClassList(ERS.get('subjs_classes'), $scope.subjects[0]));
                        if (ERS.get('classes') && Array.isArray(ERS.get('classes')))    //exclusding errors
                            ERS.set('selected_class', ERS.get('classes')[0]);
                    }
                }

                //set or restore selected items after reloading of subpage (by router)
                $scope.subject_sel = ERS.get('selected_subj');
                $scope.classes = ERS.get('classes');
                $scope.class_sel = ERS.get('selected_class');
            } //if loaded

            //fill mark list select
            setMarkList();
        }

        
        //helpers
        function setClassList(object, subj){
            var classes =[];
            if (object && Array.isArray(object))
                object.forEach(function(x){
                    if (x.subject==subj) classes=x.classes;});
            return classes;
        }

        function ifLoaded(){
            return ERS.get('subjs_classes')!=null;
        }

        function setMarkList(){
            $scope.mark_type_list=ERS.getMarkList();
            $scope.mark_list_sel=$scope.mark_type_list[0];
        }

        //!!!!MODEL LOAD AND PARSING===================================

        
        
        


    //!!!!HANDLERS AND LISTENERS+===================================

    //change listeners settings
    $scope.onChange_subj = function (x) {
        if (ifLoaded()) {
            ERS.set('selected_subj', x);
            ERS.set('classes', setClassList(ERS.get('subjs_classes'), x));
            $scope.classes = ERS.get('classes');
            if ($scope.classes) $scope.class_sel = $scope.classes[0];
        }
    };

    $scope.onChange_clas = function (x) {
        if (ifLoaded()) {
            ERS.set('selected_class', x);
        }
    };






    //NAVIGATION==========================================================================


    //helper - get date in readable format
    $rootScope.dateNow = function (td) {
        if (!td) td = new Date();
        var curr_date = td.getDate();
        var curr_month = td.getMonth() + 1;
        var curr_year = td.getFullYear();
        return curr_date + "-" + curr_month + "-" + curr_year;
    };


    //helper to write parameters to URL, write: subj, class and date to query string
    $scope.getParam=function(){
        return '#?subj='+ encodeURIComponent($scope.subject_sel)+'&'+'class='+
            encodeURIComponent($scope.class_sel)+'&'+'date='+
                encodeURIComponent(ERS.getData4MarkType($rootScope.dateNow($scope.dt), $scope.mark_list_sel));
    };


    //writeRest
    $scope.goSave = function () {
        ERS.set('works', $scope.works);
        ERS.set('topics', $scope.topics);
        ERS.sendSLRest(function(){window.location.replace('#/')});
    };


    //navigate to enter marks page
    $scope.goFuther = function () {
        if ($scope.selectform.$invalid) return;
        window.location = ERS.get("path")+ERS.get_name_from_url().join('/')+'/enter'+$scope.getParam();
    };

    //navigate to Exit
    $scope.doExit = function () {
        window.location = ERS.get("path")+"goout";
    };

    //navigate to Report
    $scope.doReport = function () {
        var path=ERS.get("path")+ERS.get_name_from_url().join('/')+"/pdf/"+encodeURIComponent($scope.class_sel)+ "/"+encodeURIComponent($scope.subject_sel);
        window.location =path;
    };


//-----------------------------------------------------------------------------------------------
//!!!!!for datapicker HELPERS


    //options to trasfer to a tag
    $scope.dateOptions = {
        dateDisabled: disabled,
        formatYear: 'yy',
        maxDate: new Date(),
        minDate: new Date(2016, 1, 1),
        startingDay: 1
    };

    // disable weekend selection
    function disabled(data) {
        var date = data.date,
            mode = data.mode;
        return mode === 'day' && (date.getDay() === 0);
    }

    //open calendar picker dialog
    $scope.openPick = function () {
        $scope.popup.opened = true;
    };

    //popup status
    $scope.popup = {
        opened: false
    };

    //set date in picker
    $scope.setDate = function (year, month, day) {
        $scope.dt = new Date(year, month, day);
    };

    //set up now date on startup
    //if it is Sunday then disable it and switch to Saturday
    var cur_date= new Date();
    if (cur_date.getDay() === 0)  cur_date=new Date(cur_date-3600*24*1000);
    $scope.dt = cur_date;

//!!!!!for datapicker HELPERS
//-------------------------------------------------------------------------------------------------



//______________________________________________________________________________________________
//for editable list modal dialog HELPERS


    //helper for updating process and indicators
    var $ctrl = this;
    $ctrl.work = " ";
    $scope.oldwork_val = " ";//save old item
    $scope.newwork = false;  //indicate a new item was added
    $scope.whattoEdit = '';  //indicate wich list is editable (for writing dialog results in a callback)
    $scope.workwith = function (name) {
        $scope.oldwork_val = name;
        $ctrl.work = name;
        if (/^\s*$/.test(name)) $scope.newwork = true;
        $ctrl.open();
    };


    //invoke dialog for for edit lists of TOPICS
    $scope.workwithTopic = function (name) {
        $scope.whattoEdit = 'topic';
        $scope.workwith(name);
    };

    //invoke dialog for for edit lists of WORKS
    $scope.workwithWork = function (name) {
        $scope.whattoEdit = 'work';
        $scope.workwith(name);
    };


    //modal dialog opening
    //-----------------------------------------------------------------------------------------------
    $ctrl.open = function (size) {
        //options
        var modalInstance = $uibModal.open({
            ariaLabelledBy: 'modal-title',
            tempariaLabelledBy: 'modal-title',
            ariaDescribedBy: 'modal-body',
            templateUrl: 'myModalContent.html',
            controller: 'ModalInstanceCtrl',  //controller is bellow
            controllerAs: '$ctrl',
            size: size,
            resolve: {
                workme: function () {
                    return $ctrl.work;        //this is transferd to modal controlle
                }
            }
        });


        //setting result to editable list (after dialog closed) depending on indicators
        //-----------------------------------------------------------------------------------------------
        modalInstance.result.then(function (editedItem) {

            var reserv;
            switch ($scope.whattoEdit) {
                case 'work':
                    reserv = $scope.works;
                    break;
                case 'topic':
                    reserv = $scope.topics;
                    break;
            }

            if ($scope.takiWork) reserv = $scope.works;
            switch (editedItem) {
                case 'cancel':
                    return;
                case 'delete':
                    reserv.splice(reserv.indexOf($scope.oldwork_val), 1);
                    break;
                default :
                    if (/^\s*$/.test(editedItem)) return;
                    if (!$scope.newwork) reserv.splice(reserv.indexOf($scope.oldwork_val), 1);
                    //correcting result - deliting wrong characters and extra words
                    editedItem=editedItem.replace(/[^0-9a-zА-Яа-яA-Z\s.іІїЇєЄґҐ`'-]/gi, '');
                    var del_extra_words=editedItem.split(/[\s]+/);
                    var split_words=[]; split_words.push(del_extra_words[0].substring(0,12));
                    if (del_extra_words.length>1) split_words.push(del_extra_words[1].substring(0,12));
                    console.log(split_words);
                    editedItem=split_words.join(" ");
                    //put result in place
                    reserv.push(editedItem);
                    $scope.newwork = false;
            }

            switch ($scope.whattoEdit) {
                case 'work':
                    $scope.works = reserv;
                    break;
                case 'topic':
                    $scope.topics = reserv;
                    break;
            }

        }, function () {

        });
    };

    //!!!!!for editable list modal dialog HELPERS
    //______________________________________________________________________________________________


}]);   //for controller

//!!!controller selectCtrl
//----------------------------------------------------------------------------------------------------




//-----------------------------------------------------------------------------------
//!!!!extra controller for Dialog Modal
app.controller('ModalInstanceCtrl', function ($uibModalInstance, workme, $scope) {
    var $ctrl = this;
    $scope.work_name = workme;

    $ctrl.ok = function () {
        $uibModalInstance.close($scope.work_name);
    };

    $ctrl.cancel = function () {
        $uibModalInstance.close('cancel');
    };

    $ctrl.delete = function () {
        $uibModalInstance.close('delete');
    };


});   //controller for Modal Dialog

//!!!!extra controller for Dialog Modal
//-----------------------------------------------------------------------------------



//-----------------------------------------------------------------------------------
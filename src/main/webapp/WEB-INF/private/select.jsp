<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page pageEncoding="UTF-8" %>
<c:url var="mypath" value="/private/"/>
<c:url var="restpath" value="/"/>


<!DOCTYPE html>
<html>

<head>


    <!--inform on outdated browser -->
    <script>
        var $buoop = {vs:{i:9,f:-6,o:-6,s:7,c:-6},unsupported:false,api:4};
        function $buo_f(){
            var e = document.createElement("script");
            e.src = "${mypath}js/outdated.js";
            document.body.appendChild(e);
        };
        try {document.addEventListener("DOMContentLoaded", $buo_f,false)}
        catch(e){window.attachEvent("onload", $buo_f)}
    </script>
    <!--inform on outdated browser -->



    <meta charset="utf-8">
  	<meta name="viewport" content="width=device-width, initial-scale=1">
  	<link rel="stylesheet" href="${mypath}css/bootstrap.min.css">
  	<link rel="stylesheet" href="${mypath}css/style3.css">
    <script src="${mypath}js/angular.min.js"></script>
</head>




<body ng-app="MyApp" ng-cloak  ng-controller="selectCtrl">




<div hidden="true" init-name="<sec:authentication property='principal.username' />" init-restpath="${restpath}"></div>




<div class="row forItems">
	<img src="../../private/icons/teacher.png"/>
</div>




  <form class="form-horizontal col-lg-10 col-lg-offset-1" role="form" ng-controller="selectCtrl as $ctrl" name="selectform" id="selectform">


      <div ng-view></div>

      <script type="text/ng-template" id="./main.htm">


      <div class="row forItems">
          <h4>Виберіть необхідну Вам сторінку класного журналу</h4>
      </div>


      <div class="row">
          <div class="form-group col-sm-6" ng-class="{ 'has-error': selectform.sel_sub.$invalid}">
              <label for="subject_sel" class="control-label col-sm-2 col-sm-offset-1">Предмет</label>
              <div class="col-sm-8">
                  <select form="selectform" id="subject_sel"  name="subject_sel" class="form-control" ng-model="subject_sel" ng-change="onChange_subj(subject_sel)" required>
                      <option value={{subject}} ng-repeat="subject in subjects">{{subject}}</option>
                  </select>
              </div>
          </div>


          <div class="form-group col-sm-6" ng-class="{ 'has-error': selectform.sel_work.$invalid}">
              <label for="sel_work" class="control-label col-sm-2 col-sm-offset-1">Опції</label>
              <div class="col-sm-8">
                  <div class="btn-group" uib-dropdown dropdown-append-to-body style="width: 100%; margin-left: 0em">
                      <a style="width: 100%; margin-left: 0em" href={{'#/edit?subj='+myExservise.get("selected_subj")}} class="btn btn-default active" role="button">Редагувати</a>
                  </div>
              </div>
          </div>

      </div>
      <div class="row">
          <div class="form-group  col-sm-6" ng-class="{ 'has-error': selectform.sel_nam.$invalid}" >
              <label for="class_sel" class="control-label col-sm-2 col-sm-offset-1">Клас</label>
              <div class="col-sm-8">
                  <select name="class_sel" id="class_sel" form="selectform" class="form-control" ng-model="class_sel" ng-change="onChange_clas(class_sel)" required>
                      <option value={{class}} ng-repeat="class in classes">{{class}}</option>
                  </select>
              </div>
          </div>


          <div class="form-group  col-sm-6">
              <label for="for_report" class="control-label col-sm-2 col-sm-offset-1">Звіт</label>
              <div class="col-sm-8">
                  <button type="button" id="for_report" class="form-control" ng-click="doReport()">Рiчний</button>
              </div>
          </div>
      </div>

      <div class="row">
          <div class="form-group  col-sm-6" ng-class="{ 'has-error': selectform.sel_nam.$invalid}" >
              <label for="mark_sel" class="control-label col-sm-2 col-sm-offset-1">Оцiнка</label>
              <div class="col-sm-8">
                  <select name="mark_sel" id="mark_sel" form="selectform" class="form-control" ng-model="mark_list_sel" ng-change="" required>
                      <option value={{mark_list}} ng-repeat="mark_list in mark_type_list">{{mark_list}}</option>
                  </select>
              </div>
          </div>

          <div class="form-group col-sm-6">
              <label for="forpicker" class="control-label col-sm-2 col-sm-offset-1">Дата</label>
              <p class="input-group col-sm-8" id="pickerframe">
                  <button name="but" id="forpicker" type="button" class="form-control glyphicon glyphicon-calendar round"
                          uib-datepicker-popup
                          ng-click="openPick()" ng-model="dt" is-open="popup.opened" datepicker-options="dateOptions"
                          current-text="Сьогодні" ng-required="true" close-text="Закрити" clear-text="Очистити"
                          minDate="dateOption.minDate" maxDate="dateOptions.maxDate">
                      <span id="pickertext">{{" "+dateNow(dt)}}</span>
                  </button>
              </p>
          </div>
      </div>


      <div class="row">
          <div class="form-group col-sm-12 forItems">
              <h5 ng-value="user" style="color: darkgreen; font-style:
              italic;">Ви обрали: <br/> {{ class_sel && subject_sel? class_sel+" "+subject_sel + "  " + dateNow(dt): 'поки нічого...' }}</h5>
          </div>

          <div class="form-group col-sm-12 forItems">
              <button ng-click="doExit()" class="btn btn-lg btn btn-warning" style="margin-right: 1em; margin-left: 1em">
                  <i class=" glyphicon glyphicon-log-out"></i>{{"  Вихiд"}}
              </button>
              <button ng-click="goFuther()" class="btn btn-lg btn btn-success" style="margin-left: 1em; margin-right: 1em;">
                  <i class="  glyphicon glyphicon-book"></i>{{"  Далi"}}
              </button>
          </div>
      </div>


      <input name="date" form="selectform" hidden="true" id="hiddenDate" type="text" value="{{dateNow (dt)}}"/>

    </script>




  <script type="text/ng-template" id="./edit.htm">

      <div class="row forItems">
          <h4>Наповніть журнал темами навчального плану та поясненнями оцінок</h4>
      </div>


      <div class="row">
          <div class="form-group col-sm-6" ng-class="{ 'has-error': selectform.sel_work.$invalid}">
              <label for="sel_work" class="control-label col-sm-2 col-sm-offset-1">Пояснення оцінки</label>
              <div class="col-sm-8">
                  <div class="btn-group" uib-dropdown dropdown-append-to-body style="width: 100%; margin-left: 0em">
                      <button id="btn-append-to-to-body" type="button" class="form-control" uib-dropdown-toggle style="width: 100%; background: #eee">
                          Редагувати список <span class="caret"></span>
                      </button>
                      <ul id="sel_work" style="width: 23.5%; min-width: 23em" class="dropdown-menu" uib-dropdown-menu role="menu" aria-labelledby="btn-append-to-to-body">
                          <li role="menuitem"><a class="btn" data-toggle="modal" style="text-align: left" data-target="#modal" ng-click="workwithWork(work)" ng-repeat="work in works"><i class="glyphicon glyphicon-edit"></i> {{work}}</a></li>
                          <li class="divider"></li>
                          <li role="menuitem"><a class="btn" data-toggle="modal" data-target="#modal" ng-click="workwithWork('')"><i class="glyphicon glyphicon-plus"></i> Додайте</a></li>
                      </ul>
                  </div>
              </div>
          </div>

          <div class="form-group col-sm-6" ng-class="{ 'has-error': selectform.sel_work.$invalid}">
              <label for="sel_top" class="control-label col-sm-2 col-sm-offset-1">Теми</label>
              <div class="col-sm-8">
                  <div class="btn-group" uib-dropdown dropdown-append-to-body style="width: 100%; margin-left: 0em">
                      <button id="btn-append-to-to-body_top" type="button" class="form-control" uib-dropdown-toggle style="width: 100%; background: #eee">
                          Редагувати список <span class="caret"></span>
                      </button>
                      <ul id="sel_top"  style="width: 23.5%; min-width: 23em"  class="dropdown-menu" uib-dropdown-menu role="menu" aria-labelledby="btn-append-to-to-body" style="width: auto">
                          <li role="menuitem"><a class="btn" data-toggle="modal" style="text-align: left" data-target="#modal" ng-click="workwithTopic(topic)" ng-repeat="topic in topics"><i class="glyphicon glyphicon-edit"></i> {{topic}}</a></li>
                          <li class="divider"></li>
                          <li role="menuitem"><a class="btn" data-toggle="modal" data-target="#modal" ng-click="workwithTopic('')"><i class="glyphicon glyphicon-plus"></i> Додайте</a></li>
                      </ul>
                  </div>
              </div>
          </div>
      </div>
      <div class="row">
          <div class="form-group col-sm-12 forItems">
              <h5 ng-value="user" style="color: darkgreen; font-style:
                  italic;">Відредагуйте довідники, <br/>що містять потрібну інформацію  <br>з предмету - <b>{{myExservise.get('selected_subj')}} </b></h5>
          </div>
      </div>
      <div class="row">
          <div class="form-group col-sm-12 forItems">
              <a id="likebutton" href="#/" class="btn btn-lg btn btn-warning" style="margin-right: 1em; margin-left: 1em">
                  <i class="glyphicon glyphicon-hand-left"></i>{{" Скасувати"}}
              </a>
              <button ng-click="goSave()" class="btn btn-lg btn btn-success" style="margin-left: 1em; margin-right: 1em;">
                  <i class="glyphicon glyphicon-floppy-open"></i>{{" Записати"}}
              </button>
          </div>
      </div>
  </script>


  </form>




<script type="text/ng-template" id="myModalContent.html">
    <div class="modal-header">
        <h3 class="modal-title" id="modal-title">Відредагуйте вміст</h3>
    </div>
    <form>
    <div class="modal-body" id="modal-body">
        <div class="form-group">
            <label for="exampleInput">Коротка (до 2 коротких слів) назва</label>
            <input type="text" class="form-control" id="exampleInput" ng-model="work_name" placeholder="Работа" autofocus>
        </div>
    </div>
    </form>
    <div class="modal-footer">
        <button class="btn btn-success" style="padding-right: 4em; padding-left: 4em" type="button" ng-click="$ctrl.ok()">OK</button>
        <button class="btn btn-primary" type="button" ng-click="$ctrl.cancel()">Вихiд</button>
        <button class="btn btn-warning" type="button" ng-click="$ctrl.delete()">Видалити</button>
    </div>
</script>




</div>


<!-- Angular Material requires Angular.js Libraries -->
  <script src="${mypath}js/angular-route.min.js"></script>
  <script src="${mypath}js/ui-bootstrap-tpls-2.2.0.min.js"></script>
  <script src="${mypath}js/angular-locale_ru-ru.js"></script>
  <script src="${mypath}js/select_serv.js"></script>
  <script src="${mypath}js/select_contr.js"></script>




</body>
</html>

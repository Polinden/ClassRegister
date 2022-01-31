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




    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	    <script src="${mypath}js/angular.min.js"></script>
        <link rel="stylesheet" href="${mypath}css/bootstrap.min.css" />
        <link href="${mypath}css/style4.css" rel="stylesheet">
</head>


<body ng-app="myApp" ng-controller="safeCtrl" ng-cloak>



<div hidden="true" init-name="<sec:authentication property='principal.username' />" init-restpath="${restpath}" callon-rest="startingUp(path, name)"></div>


<div class="container">
    <div class="row" >


            <div class="col-md-3 col-sm-4">
                    <div class="row">
                        <div class="col-md-12 affixs" id="leftsidetitle">
                            <h1 id="forsidetitle">{{subject_sel}}
                                <p class="lead">{{studentName}}</p>
                            </h1>
                        </div>
                    </div>


                    <div class="row leftmenubar">
                        <nav class="col-md-12" id="leftnavbar">
                            <ul class="nav nav-pills nav-stacked affixs" id="leftmenuitems">
                                <li class="subjlist" ng-repeat="subject in subjects track by $index"><a ng-click="newSubj(subject)">
                                    <i class=" glyphicon glyphicon-folder-open" style="width: 2em"></i>{{subject}}</a></li>
                            </ul>
                        </nav>
                    </div>
            </div>


            <div class="col-md-9 col-sm-8" id="forright">
                        <div  class="row" id="context">
                            <p class="smalltopics visible-xs"></p>
                            <p class="bigtopics visible-sm visible-md visible-lg"></p>
                            <div class="col-md-12" ng-repeat="row in rowCollection track by $index">

                                <uib-accordion>
                                    <div uib-accordion-group class="panel-default" template-url="group-template.html" id="for_topic"
                                         heading="{{row.toppic_string +' '+row.topic}}" is-open="false">

                                        <table st-table="displayedCollection" st-safe-src="row.entries" class="table">
                                            <thead>
                                            <tr>
                                                <th style="width: 20%"> Дата</th>
                                                <th style="width: 5%"> Бал</th>
                                                <th style="width: 32%">Вид роботи</th>
                                                <th> Примітка</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <tr ng-repeat="row1 in displayedCollection track by $index" ng-style="($index%2)==0?mySt1:mySt2">
                                                <td style="text-align: left" ng-click="goEdit(row1.date)">{{row1.date}}</td>
                                                <td style="text-align: left; color: #2b542c"><b>{{row1.mark}}</b></td>
                                                <td style="text-align: left">{{row1.work}}</td>
                                                <td style="text-align: left">{{row1.comment}}</td>
                                            </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </uib-accordion>

                                <div class="alert alert-warning" id="for_sum">{{row.bottom_string+' '+row.avermark}}</div>
                            </div>

                            <div  class="row">
                                <div id="forbutton" class="form-group col-xs-12">
                                    <button type="button" ng-click="doBack()" ng-class="if_a_prepod ? ['glyphicon-hand-left','btn-success'] : ['glyphicon-log-out','btn-warning']" class="btn  glyphicon">
                                        <span style="font-family: Helvetica, Arial, sans-serif" ng-bind="if_a_prepod ? ' Назад':'  Вихiд'"></span>
                                    </button>
                                    <span class="forbutspan"></span>
                                    <button type="button" ng-click="doExit()" class="btn btn-warning glyphicon glyphicon-log-out" ng-show="if_a_prepod">
                                        <span style="font-family: Helvetica, Arial, sans-serif">{{" Вихiд"}}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>


    </div><!--/row-->
</div><!--/container-->






<script type="text/ng-template" id="group-template.html">
    <div class="panel panel-default" style="border-color: gainsboro"  style="padding-bottom: 0em">
        <div class="panel-heading" style="background-color: rgb(158, 185, 144); border-color: rgb(158, 185, 144);">
            <h4 class="panel-title" style="background-color: rgb(158, 185, 144);">
                <a href tabindex="0" class="accordion-toggle" ng-click="toggleOpen()" uib-accordion-transclude="heading">
							<span uib-accordion-header ng-class="{'text-muted': isDisabled}">
									<i ng-class="{'glyphicon glyphicon-collapse-down' : !isOpen, 'glyphicon glyphicon-collapse-up': isOpen}"></i>
									{{heading}}
							</span>
                </a>
            </h4>
        </div>
        <div class="panel-collapse collapse" uib-collapse="!isOpen">
            <div class="panel-body" style="text-align: right; padding: 0" ng-transclude></div>
        </div>
    </div>
</script>



<script src="${mypath}js/smart-table.min.js"></script>
<script src="${mypath}js/ui-bootstrap-tpls-2.2.0.min.js"></script>
<script src="${mypath}js/stud_stat_serv.js"></script>
<script src="${mypath}js/stud_status_cont.js"></script>


</body>
</html>
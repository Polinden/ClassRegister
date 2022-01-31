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
	<link rel="stylesheet" href="${mypath}css/style.css" />
</head>


<body ng-app="myApp" ng-controller="tableCtrl" ng-cloak>



<div hidden="true" init-name="<sec:authentication property='principal.username' />" init-restpath="${restpath}" callon-rest="startingUp(path, name)"></div>


	<div class="container">
	<form name="myForm" id="myForm">

		<div  class="row fortable" ng-hide="if_year_summary">
			<div class="form-group col-md-3 col-xs-12 col-sm-6" ng-class="{'has-error': myForm.sel_top.$invalid}">
				<img src="${mypath}/icons/list_topics.PNG"/>
				<label for="sel_top">Тема навчального плану</label>
				<select name="sel_top" id="sel_top" form="myForm" class="form-control" ng-model="selected_top" ng-change="settopics_list()" ng-required="!if_year_summary">
					<option ng-value="class" ng-repeat="topic in topics_list track by $index">{{topic}}</option>
				</select>
			</div>
			<div class="form-group col-md-3 col-sm-12">
				<img src="${mypath}/icons/show_mark.png"/>
				<label>Дату видно</label><br/>
				<div class="btn-group" id="forswitch">
					<label class="btn btn-default" ng-model="show_d" uib-btn-radio="true">Так</label>
					<label class="btn btn-default" ng-model="show_d" uib-btn-radio="false">Ні</label>
				</div>
			</div>
			<h3 style="text-align: left;" class="for_title col-md-4 col-sm-6 col-xs-12">{{subjTitle+" "}}
				<br class="visible-sm visible-md visible-lg"/>{{classTitle}}
			</h3>
			<h3 style="text-align: right;" class="for_title col-sm-6 col-md-2 col-xs-12">{{'Журнал'+' '}}
				<br class="visible-sm visible-md visible-lg"/>{{dateTitle}}
			</h3>
		</div>


		<div  class="row fortable" ng-hide="!if_year_summary">
			<h3 style="text-align: left;" class="for_title col-sm-4 col-xs-12">{{subjTitle+" "}}
				<br class="visible-sm visible-md visible-lg"/>{{classTitle}}
			</h3>
			<div class="for_image col-sm-4 visible-sm visible-md visible-lg">
				<img class="visible-md visible-lg" src="${mypath}/icons/summary.png"/>
				<h3 id="year_summary" class="for_title">
					{{'Підсумки '+summary_year}}
				</h3>
			</div>
			<h3 style="text-align: right;" class="for_title col-sm-4 col-xs-12">{{'Вид оцінки '}}
				<br class="visible-sm visible-md visible-lg"/>{{'"'+year_summary_tile+'"'}}
			</h3>
		</div>

		<p style="height: 1em"/>


		<div  class="row">

			<div class="col-xs-12">

				<table st-table="displayedCollection" st-safe-src="tableModel" class="table">
					<thead>
						<tr style="background-color: #d8c6a2">
							<th style="width: 20%; cursor: pointer" st-sort="lastName" st-sort-default="true">
								<i class="glyphicon glyphicon-arrow-down">
								<span>{{" Прізвище"}}</span></i>
							</th>
							<th style="width: 10%">Ім'я</th>
							<th style="width: 4%"> <i class="glyphicon glyphicon-user"></i></th>
							<th style="width: 9%"> Оцінка</th>
							<th style="width: 18%"> Пояснення оцінки</th>
							<th style="width: 5%"> </th>
							<th style="width: 30%">Примітка</th>
							<th style="width: 4%"> </th>
						</tr>
						<tr>
							<th colspan="13"><input st-search="" class="form-control" placeholder="поиск по списку..." type="text"/></th>
						</tr>
						</thead>
						<tbody>
						<tr ng-repeat="row in displayedCollection track by $index" ng-style="($index%2)==0?mySt1:mySt2">
							<td><span class="tostud" ng-click="goName(row)"><b>{{row.firstname}}</b></span></td>
							<td>{{row.secondname}}</td>
							<td>
								<input type="checkbox" ng-change="doDissable(row)" ng-model="row.present" uib-tooltip="Присутній?"/>
							</td>
							<td>
								<input class="form-control" type="number" min="0" max="12" style="width: 6em" ng-class="{dissabled: !row.present}"
									   ng-pattern="regex" ng-model="row.mark" ng-disabled="!row.present" tabindex={{$index+1}} onfocus="this.select();">
							</td>
							<td>
								<select ng-model="row.work" ng-required="row.present && !if_year_summary" ng-disabled="!row.present || if_year_summary" name="sel_work" id="sel_work" class="form-control" >
									<optgroup label="Регулярні">
										<option ng-repeat="y in works_list track by $index" value={{y}}>{{y}}</option>
									</optgroup>
									<optgroup label="Підсумкові">
										<option ng-repeat="r in works_summary track by $index" value={{r}}>{{r}}</option>
									</optgroup>
								</select>
							</td>
							<td>
								<button type="button" ng-click="copyworks_list(row)" class="btn btn-sm btn-success"  ng-disabled="!row.present">
									<i class="glyphicon glyphicon-link"></i>
								</button>
							</td>
							<td>
								<input class="form-control" type="text" ng-model="row.comment" maxlength="40"/>
							</td>
							<td>
								<button type="button" ng-click="copyRemark(row)" class="btn btn-sm btn-success"  ng-disabled="!row.present">
										<i class="glyphicon glyphicon-link"></i>
								</button>
							</td>
						</tr>
					</tbody>
				</table>

			</div>
		</div>

		<div  class="row">
			<div class="col-xs-12" id="forbutton" style="margin-top: 2em">
				<button type="button"  class="btn btn-primary glyphicon glyphicon-hand-left"
						uib-tooltip="{{myForm.$dirty? 'Сначала сохраните форму' : ''}}" tooltip-placement="bottom-left" ng-click="doBack()">
					<span>{{"    Назад "}}</span>
				</button>
				<button type="button"  class="btn btn-success glyphicon glyphicon glyphicon-log-out" uib-tooltip="{{myForm.$dirty? 'Сначала сохраните форму' : ''}}"
						tooltip-placement="bottom-left"ng-click="doExit()">
					<span>{{"    Вихід"}}</span>
				</button>
				<button type="button"  ng-click="doSend()" class="btn btn-warning glyphicon glyphicon-floppy-open">
					<span>{{" Зберегти"}}</span>
				</button>
			</div>

			<div id="for_alert">
				<div id="allert_mes" ng-repeat="alert in alerts" uib-alert class="alert-success " dismiss-on-timeout=1000 close="close_alert($index)">
					{{alert.msg}}
				</div>
			</div>

		</div>



	</form>


	</div>

	<img id="totop" src="${mypath}icons/to_top.png" onclick="window.scrollTo(0, 0);"/>



	<script src="${mypath}js/smart-table.min.js"></script>
	<script src="${mypath}js/ui-bootstrap-tpls-2.2.0.min.js"></script>
	<script src="${mypath}js/ent_mark_serv.js"></script>
	<script src="${mypath}js/ent_mark_cont.js"></script>

</body>


</html>

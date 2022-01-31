<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page pageEncoding="UTF-8" %>
<c:url var="mypath" value="/private/"/>
<html>
<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title>Ошибка!!!</title>
    <link rel="stylesheet" href="${mypath}/css/bootstrap.min.css">
</head>
<body>
<div class="container" style="margin-top: 6em">
    <div class="jumbotron">
        <h1 style="color: red">Порушення прав доступу</h1>
        <h3 style="color: darkgreen">Зауважте, Ваш IP збережений в журналі порушень!</h3>
    </div>
</div>
</body>
</html>


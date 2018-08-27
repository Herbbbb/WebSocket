<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<%=basePath%>">
 
<title>My JSP 'login.jsp' starting page</title>
 
</head>
 
<body>
<center>
	<form action="chatWebsocket/login.do" method="post">
		<table>
			<tr>
				<td>username:</td><td><input type="text" id="username" name="username"/></td>
			</tr>
			<tr>
				<td colspan="2"> <input type="submit" value="登录"/></td>
			</tr>
		</table>
	</form>
</center>
</body>
</html>

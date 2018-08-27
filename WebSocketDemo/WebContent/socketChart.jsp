<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
 
<title>My JSP 'socketChart.jsp' starting page</title>
<script type="text/javascript" src="../jquery.js"></script>
</head>
 
<body>
	${username}<br/>
	在线人数:<div id="onlineCount">0</div>
	<br />
	发送对象:<input id="username" type="text" width="50px"/>内容:<input id="text" type="text" />
	<button onclick="send()">发送消息</button>
	<hr />
	<button onclick="closeWebSocket()">关闭WebSocket连接</button>
	<hr />
	<div id="message"></div>
</body>
<script type="text/javascript">
	var websocket = null;
	//判断当前浏览器是否支持WebSocket
	if ('WebSocket' in window) {
		websocket = new WebSocket("ws://localhost:8080/WebSocketDemo/websocketTest ");
	} else {
		alert('当前浏览器 Not support websocket')
	}
	//连接发生错误的回调方法
	websocket.onerror = function() {
		setMessageInnerHTML("WebSocket连接发生错误");
	};
	//连接成功建立的回调方法
	websocket.onopen = function() {
		setMessageInnerHTML("WebSocket连接成功");
	}
	//接收到消息的回调方法
	websocket.onmessage = function(event) {
			
		
		var messageJson=eval("("+event.data+")");
		if(messageJson.messageType=="message"){
			console.log(messageJson.data);
			console.log('----------------------');
			setMessageInnerHTML(messageJson.data);
		}
		if(messageJson.messageType=="onlineCount"){
			document.getElementById('onlineCount').innerHTML=messageJson.data;
		}
		
	}
	//连接关闭的回调方法
	websocket.onclose = function() {
		setMessageInnerHTML("WebSocket连接关闭");
	}
	//监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。
	window.onbeforeunload = function() {
		closeWebSocket();
	}
	//将消息显示在网页上
	function setMessageInnerHTML(innerHTML) {
		document.getElementById('message').innerHTML += innerHTML + '<br/>';
	}
	//关闭WebSocket连接
	function closeWebSocket() {
		websocket.close();
	}
	//发送消息
	function send() {
		var message = document.getElementById('text').value;
		var username = document.getElementById('username').value;
		websocket.send(username+"@"+message);
		document.getElementById('message').innerHTML += message + '<br/>';
	}
</script>
</html>
 

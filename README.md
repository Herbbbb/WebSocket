# WebSocketDemo
WebSocket实现即时聊天

# 基于SpringMVC技术和WebSocket
# Tomcat需8.0及以上
# 常见问题及BUG：

# 建立连接成功，马上提示WebSocket连接关闭
> Tomcat版本需要8.0及以上，版本过低的没有WebSocket的相关Jar或者不支持WebSocket

# 无法找到ws://localhost:8080/WebSocketDemo/webSocketTest
> 首先检查路径是否正确，对应的@ServerPoint注解是否和webSocketTest一致
> 检查访问的是本地还是外地服务器，建议将localhost统一换成服务器地址
> Gson的jar是否在pom文件或者手动导入过
# WebSocket connection to 'ws://localhost:8080/CollabEdit/echo' failed: Error during WebSocket handshake: Unexpected response code: 404
     > 这个问题也是在调试成功之前一直困扰我的问题，最终定位到是Tomcat依赖的WebSocketjar包版本过低，解决方案先提供以下两种：

> 将项目直接部署在Tomcat8.0及以上的版本运行
> 将依赖的WebSocket的jar从Tomcat8.0及以上中手动挑选出，部署在项目中，然后部署到低版本就没有问题了。我在实践中采取的是：Tomcat8.0的jar打成war，部署在Tomcat7.0上，可以成功启动
# 发送的消息在接收方窗口没有接收到
      # 请注意看WebSocket核心的如下代码：
```
String targetname=messageStr.substring(0, messageStr.indexOf("@"));
String sourcename="";
    for (Entry<String,WebSocketTest> entry  : webSocketMap.entrySet()) {
		//根据接收用户名遍历出接收对象
		if(targetname.equals(entry.getKey())){
			try {
				for (Entry<String,WebSocketTest> entry1  : webSocketMap.entrySet()) {
					//session在这里作为客户端向服务器发送信息的会话，用来遍历出信息来源
					if(entry1.getValue().session==session){
						sourcename=entry1.getKey();
					}
				}
				MessageDto md=new MessageDto();
				md.setMessageType("message");		            
                md.setData(sourcename+":"+message.substring(messageStr.indexOf("@")+1));
				entry.getValue().sendMessage(gson.toJson(md));
    }
    ```
       > 也就是说，接收消息的一方，必须在Session中是存在的，可以简单的理解为一个容器，用户一旦登陆，就会进入该容器，当需要发送消息时，会按照接收方的username或其他等同信息(id/number...)去容器寻找，找到就会将对应的消息发送给接收方

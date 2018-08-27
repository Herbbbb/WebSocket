package com.test.socket;
 
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
 
import javax.servlet.http.HttpSession;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.chart.dto.MessageDto;
import com.google.gson.Gson;
 
/**
 * @ServerEndpoint
 */
@ServerEndpoint("/websocketTest")
public class WebSocketTest {
	private static int onlineCount = 0;
	//存放所有登录用户的Map集合，键：每个用户的唯一标识（用户名）
	private static Map<String,WebSocketTest> webSocketMap = new HashMap<String,WebSocketTest>();
	//session作为用户简历连接的唯一会话，可以用来区别每个用户
	private Session session;
	//httpsession用以在建立连接的时候获取登录用户的唯一标识（登录名）,获取到之后以键值对的方式存在Map对象里面
	private static HttpSession httpSession;
	
	public static void setHttpSession(HttpSession httpSession){
		WebSocketTest.httpSession=httpSession;
	}
	/**
	 * 连接建立成功调用的方法
	 * @param session
	 * 可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据
	 */
	@OnOpen
	public void onOpen(Session session) {
		Gson gson=new Gson();
		this.session = session;
		webSocketMap.put((String) httpSession.getAttribute("username"), this);
		addOnlineCount(); // 
		MessageDto md=new MessageDto();
		md.setMessageType("onlineCount");
		md.setData(onlineCount+"");
		sendOnlineCount(gson.toJson(md));
		System.out.println(getOnlineCount());
	}
	/**
	 * 向所有在线用户发送在线人数
	 * @param message
	 */
	public void sendOnlineCount(String message){
		for (Entry<String,WebSocketTest> entry  : webSocketMap.entrySet()) {
			try {
				entry.getValue().sendMessage(message);
			} catch (IOException e) {
				continue;
			}
		}
	}
	
	/**
	 * 连接关闭调用的方法
	 */
	@OnClose
	public void onClose() {
		for (Entry<String,WebSocketTest> entry  : webSocketMap.entrySet()) {
			if(entry.getValue().session==this.session){
				webSocketMap.remove(entry.getKey());
				break;
			}
		}
		//webSocketMap.remove(httpSession.getAttribute("username"));
		subOnlineCount(); // 
		System.out.println(getOnlineCount());
	}
 
	/**
	 * 服务器接收到客户端消息时调用的方法，（通过“@”截取接收用户的用户名）
	 * 
	 * @param message
	 *            客户端发送过来的消息
	 * @param session
	 *            数据源客户端的session
	 */
	@OnMessage
	public void onMessage(String message, Session session) {
		Gson gson=new Gson();
		System.out.println("收到客户端的消息:" + message);
		StringBuffer messageStr=new StringBuffer(message);
		if(messageStr.indexOf("@")!=-1){
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
					} catch (IOException e) {
						e.printStackTrace();
						continue;
					}
				}
				
			}
		}
		
	}
 
	/**
	 * 发生错误时调用
	 * 
	 * @param session
	 * @param error
	 */
	@OnError
	public void onError(Session session, Throwable error) {
		error.printStackTrace();
	}
 
	/**
	 * 这个方法与上面几个方法不一样。没有用注解，是根据自己需要添加的方法。
	 * 
	 * @param message
	 * @throws IOException
	 */
	public void sendMessage(String message) throws IOException {
		this.session.getBasicRemote().sendText(message);
		// this.session.getAsyncRemote().sendText(message);
	}
 
	public static synchronized int getOnlineCount() {
		return onlineCount;
	}
 
	public static synchronized void addOnlineCount() {
		WebSocketTest.onlineCount++;
	}
 
	public static synchronized void subOnlineCount() {
		WebSocketTest.onlineCount--;
	}
}

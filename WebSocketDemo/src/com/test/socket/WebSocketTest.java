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
	//������е�¼�û���Map���ϣ�����ÿ���û���Ψһ��ʶ���û�����
	private static Map<String,WebSocketTest> webSocketMap = new HashMap<String,WebSocketTest>();
	//session��Ϊ�û��������ӵ�Ψһ�Ự��������������ÿ���û�
	private Session session;
	//httpsession�����ڽ������ӵ�ʱ���ȡ��¼�û���Ψһ��ʶ����¼����,��ȡ��֮���Լ�ֵ�Եķ�ʽ����Map��������
	private static HttpSession httpSession;
	
	public static void setHttpSession(HttpSession httpSession){
		WebSocketTest.httpSession=httpSession;
	}
	/**
	 * ���ӽ����ɹ����õķ���
	 * @param session
	 * ��ѡ�Ĳ�����sessionΪ��ĳ���ͻ��˵����ӻỰ����Ҫͨ���������ͻ��˷�������
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
	 * �����������û�������������
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
	 * ���ӹرյ��õķ���
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
	 * ���������յ��ͻ�����Ϣʱ���õķ�������ͨ����@����ȡ�����û����û�����
	 * 
	 * @param message
	 *            �ͻ��˷��͹�������Ϣ
	 * @param session
	 *            ����Դ�ͻ��˵�session
	 */
	@OnMessage
	public void onMessage(String message, Session session) {
		Gson gson=new Gson();
		System.out.println("�յ��ͻ��˵���Ϣ:" + message);
		StringBuffer messageStr=new StringBuffer(message);
		if(messageStr.indexOf("@")!=-1){
			String targetname=messageStr.substring(0, messageStr.indexOf("@"));
			String sourcename="";
			for (Entry<String,WebSocketTest> entry  : webSocketMap.entrySet()) {
				//���ݽ����û������������ն���
				if(targetname.equals(entry.getKey())){
					try {
						for (Entry<String,WebSocketTest> entry1  : webSocketMap.entrySet()) {
							//session��������Ϊ�ͻ����������������Ϣ�ĻỰ��������������Ϣ��Դ
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
	 * ��������ʱ����
	 * 
	 * @param session
	 * @param error
	 */
	@OnError
	public void onError(Session session, Throwable error) {
		error.printStackTrace();
	}
 
	/**
	 * ������������漸��������һ����û����ע�⣬�Ǹ����Լ���Ҫ��ӵķ�����
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

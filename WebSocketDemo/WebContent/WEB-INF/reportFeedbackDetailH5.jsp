<%@ page language="java" contentType="text/html" pageEncoding="utf-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html>  
<html>  
<head>  
    <meta charset="utf-8">  
    <meta name="viewport" content="initial-scale=1,maxmum-scale=1,minimumscale=1" />
    <title>HTML5模拟微信聊天界面</title>  
    <script type="text/javascript" src="jslib/jquery.min.js"></script>
    <style>  
  /**重置标签默认样式*/   
        * {   
            margin: 0;   
            padding: 0;   
            list-style: none;   
            font-family: '微软雅黑' ;
            font-size:0.16rem;  
        }   
        body,html{
       		height:100%;
       		width:100%;
        }
       /*  body{
        	position:absolute;
        	top:0px;
        } */
        #container {   
            width: 100%;   
            height: 100%;   
            background: #eee;    
        }   
        .header {   
       		width:92%;
            background: white; 
            border:2px solid #ccc;
            border-radius:5px;  
            overflow:hidden;   
            color: #000;   
            line-height: 34px;   
            font-size: 20px; 
            margin:0 0.1rem;  
            padding:0.1rem;   
        }   
        .footer {   
            width: 96%;  
            height: 0.5rem;
            background: #666;   
            position: fixed;   
            bottom: 0;   
            padding: 0.1rem;  
        }   
        .footer input {   
            width: 80%;   
            height: 0.45rem;   
            outline: none;   
            font-size: 0.2rem;   
            text-indent: 0.1rem;   
           
            border-radius: 0.06rem;   
            
        }   
        .footer span {   
            display: inline-block;   
            width: 13%;   
            margin-left:2%;
            height: 0.45rem;   
            background: #ccc;   
            font-weight: 900;   
            line-height: 0.45rem;   
            cursor: pointer;   
            text-align: center;   
            border-radius: 0.06rem;   
        }   
        .footer span:hover {   
            color: #fff;   
            background: #999;   
        }   
        #user_face_icon {   
            display: inline-block;   
            background: white;   
            width: 60px;   
            height: 60px;   
            border-radius: 30px;   
            position: absolute;   
            bottom: 6px;   
            left: 14px;   
            cursor: pointer;   
            overflow: hidden;   
        }   
        img {   
            width: 70px;   
            height: 60px;   
        }   
        .content {   
        	height:780px;
            font-size: 0.2rem;   
            width: 98%; 
            overflow: auto;   
            padding: 0.05rem; 
            padding-bottom: 0.1rem;  
        }  

        .content li {   
            margin-top: 10px;   
            padding-left: 10px;   
            width: 95%;   
            display: block;   
            clear: both;   
            overflow: hidden;   
        }   
        .content li img {   
            float: left;   
        }   
        .content li span{   
            background: #7cfc00;   
            padding: 10px;   
            border-radius: 10px;   
            display:inline-block;
            max-width: 310px;   
            border: 1px solid #ccc;   
            box-shadow: 0 0 3px #ccc;  
            word-wrap:break-word;
            white-space:normal; 
        }   
        .content li img.imgleft {    
            float: left;    
        }   
        .content li img.imgright {    
            float: right;    
        }   
        .content li span.spanleft {    
            float: left;   
            background: #fff;   
        }   
        .content li span.spanright {    
            float: right;   
            background: #7cfc00;   
        }   
        .info{
        	overflow:hidden;
        }
        .info .detail-img {
			text-align: center;
		}
		
		.info .detail-img img {
			height: 20%;
			width: 15%;
			cursor: pointer;
		}
        .detail-title h3{
        	font-size:0.18rem;
        	text-align:center;
        }
        .origin{
        	text-align:center;
        }
        .origin>div{
        	display:inline-block;
        }
        .left{
        	float:left!important;
        }
         .right{
        	float:right!important;
        }
    </style>  
    <script>  
    var wd = document.documentElement.clientWidth*window.devicePixelRatio/10.8;
	$("html").css({"font-size":wd+'px'});
    
    var websocket = null;
	//判断当前浏览器是否支持WebSocket
	if ('WebSocket' in window) {
		websocket = new WebSocket('ws://localhost:8080/dbportal-web/websocketTest');
	} else {
		alert('当前浏览器 Not support websocket')
	}
	//连接发生错误的回调方法
	websocket.onerror = function() {
		alert("WebSocket连接发生错误");
	};
        window.onload = function(){   
           // var arrIcon = ['img/asker.bmp','img/tl.png'];   
            var iNow = -1;    //用来累加改变左右浮动  
            var num = 0;     //控制头像改变
            var btn = document.getElementById('btn');   
            //var icon = document.getElementById('user_face_icon').getElementsByTagName('img');
            var text = document.getElementById('textByWx');   
            var content = document.getElementsByTagName('ul')[0];   
           // var img = content.getElementsByTagName('img');   
            var span = content.getElementsByTagName('span'); 
            var username = ${toUser};  
  
            btn.onclick = function(){   
                if(text.value ==''){   
                    alert('不能发送空消息');   
                }else {   
                	var message = document.getElementById('textByWx').value;
            		
            		console.log(username);
            		websocket.send(username+"@"+message);
            		
                    content.innerHTML += '<li class="one"><span>'+message+'</span></li>'; 
                   /*  content.innerHTML += '<li><img src="'+arrIcon[0]+'"><span>'+message+'</span></li>';  */
                    iNow++;
                    console.log(message)
                    for(var i=0;i<$(".content li").length;i++){
        				if($(".content li").eq(i).attr('class').match(/one/)){
	        			 	console.log(1)
	                    	$(".content li").eq(i).find('span').addClass("right");
	                    }else{
	                    	console.log(2)
	                   		$(".content li").eq(i).find('span').addClass("left");
	                    }
        			}
                }  
                    text.value = '';   
				     // 内容过多时,将滚动条放置到最底端   
						content.scrollTop=content.scrollHeight; 
						console.log(content.scrollTop) ;
						console.log(content.scrollHeight) ;

                  
            }
            websocket.onmessage = function(event) {
            	var messageJson=eval("("+event.data+")");
        		if(messageJson.messageType=="message"){
        			console.log(messageJson)
        			content.innerHTML += '<li class="two"><span>'+messageJson.data+'</span></li>';
        			console.log(typeof(messageJson.data));
        			var m = username.toString();
        			
        			var te = messageJson.data;
        			for(var i=0;i<$(".content li").length;i++){
        				if($(".content li").eq(i).attr('class').match(/one/)){
	        			 	console.log(3)
	                    	$(".content li").eq(i).find('span').addClass("right");
	                    }else{
	                    	console.log(3)
	                   		$(".content li").eq(i).find('span').addClass("left");
	                    }
        			}
        			 
        			//content.innerHTML += '<li><img src="'+arrIcon[1]+'"><span>'+messageJson.data+'</span></li>';
        			 //$('img').addClass('imgleft');   
        			 //$('span').addClass('spanleft');  
        		}
        		content.scrollTop=content.scrollHeight; 
            }
            
           
        }   
    </script>  
</head>  
<body>  
    <div id="container">  
        <div class="header">  
                                  
            <!-- <input id="username" type="text"/> -->
            <!-- <span style="float: left;">报表和自助取数平台</span> -->  
            <span class="time" style="float: right;">欢迎 ${username}</span>  
            <div class="info">
	        	<div class="title">
					<div class="row">
						<div class="detail-title text-center">
							<h3>${detalMap.tReportFeedback.reportName}</h3>
						</div>
					</div>
				</div>
				<div class="row text-center origin">
					<div id="createTime">${detalMap.tReportFeedback.createTime}</div>
					<div id="userNm">提问人：XXX</div>
					<div id="orgNm">机构：XXXXXXXX</div>
				</div>
				<div class="detail-img text-center">
					<p>
						<img src="./image.do?imgPath=${detalMap.tReportFeedback.picPath}"
							class="" alt="pic" title="pic">
					</p>
				</div>
	        </div> 
        </div>  
       
         <ul class="content"></ul>  
      	<div class="footer">  
             
            <input id="textByWx" type="text" placeholder="说点什么吧...">  
            <span id="btn">发送</span>  
        </div>  
    </div>  
</body>  
</html>  
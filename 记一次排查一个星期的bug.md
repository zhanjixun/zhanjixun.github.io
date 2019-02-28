# 记一次排查一个星期的bug

​	 自打学开发以来，所在的所有的http请求都是用apache的commons-httpclient发的，也知道这个框架已经年久失修，但是一直用着没发现什么问题，也没想去换。直到某一天，遇到一个让我排查一个星期的bug...

​	Bug：commons-httpclient发送GET请求一直得不到想要的结果

​	事件起因：闲来无事做嘛，就想研究一下微信网页版。

​	步骤很清晰：

1. 获取UUID  

2. 使用UUID获取二维码

3. 手机扫描二维码

4. 轮询等待扫码获得跳转地址

5. 访问跳转地址获得微信认证码

6. 使用认证码进行web微信初始化

7. 轮询检查是否有消息

8. ...

   ​

   思路很简单嘛，就一个个的http请求发过去就行了，一开始用的commons-httpclient发的请求，写的代码是这样子的：

   ``` Java
   package com.zhanjixun.weixin.test;

   import com.alibaba.fastjson.JSON;
   import com.alibaba.fastjson.JSONObject;
   import com.google.common.collect.Maps;
   import com.zhanjixun.weixin.domain.AuthInfo;
   import com.zhanjixun.weixin.frame.ImageFrame;
   import lombok.extern.log4j.Log4j;
   import org.apache.commons.httpclient.HttpClient;
   import org.apache.commons.httpclient.methods.GetMethod;
   import org.apache.commons.httpclient.methods.PostMethod;
   import org.apache.commons.httpclient.methods.StringRequestEntity;
   import org.apache.commons.lang3.RandomStringUtils;
   import org.apache.commons.lang3.StringUtils;
   import sun.misc.BASE64Decoder;

   import javax.imageio.ImageIO;
   import java.awt.image.BufferedImage;
   import java.io.*;
   import java.net.URLEncoder;
   import java.util.Map;
   import java.util.stream.Collectors;

   /**
    * @author :zhanjixun
    * @date : 2018/10/25 6:38
    */
   @Log4j
   public class Demo2 {

       private static final String TEMP_DIR = System.getProperty("java.io.tmpdir");

       private static HttpClient httpClient = new HttpClient();

       public static void main(String[] args) throws IOException {
           //1.获取UUID
           String uuid = uuid();
           //2.获取二维码
           BufferedImage bufferedImage = qrCodeImage(uuid);

           //显示二维码
           ImageFrame imageFrame = new ImageFrame(downloadImage(bufferedImage, "QRCode.jpg"));
           imageFrame.setVisible(true);

           //3.轮询等待扫码
           String redirectUri;
           while (true) {
               Map<String, String> waitScan = waitScan(uuid);
               if (waitScan.get("code").equals("408")) {
                   continue;
               }
               if (waitScan.get("code").equals("400")) {
                   log.info("扫码超时");
                   System.exit(0);
               }
               if (waitScan.get("code").equals("201")) {
                   log.info("请在手机端确认登录");
                   imageFrame.setImage(base64Image(waitScan.get("userAvatar"), "userAvatar.jpg"));
               }
               if (waitScan.get("code").equals("200")) {
                   log.info("登录成功");
                   redirectUri = waitScan.get("redirectUri");
                   imageFrame.setVisible(false);
                   imageFrame.dispose();
                   break;
               }
           }
           //4.获取微信认证码
           AuthInfo ticket = ticket(redirectUri);
           //5.初始化
           JSONObject initMap = init(ticket);
           log.info("欢迎：" + initMap.getJSONObject("User").getString("NickName"));
   ```




           // 下面开始构造这个http请求，一直得到不了应有的结果
           String syncKey = initMap.getJSONObject("SyncKey").getJSONArray("List").stream().map(d -> (JSONObject) d).map(d -> d.getString("Key") + "_" + d.getString("Val")).collect(Collectors.joining("|"));
           String url = "https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck?skey=#{skey}&sid=#{sid}&uin=#{uin}&synckey=#{synckey}";
           url = url.replace("#{skey}", urlEncode(ticket.getSkey()));
           url = url.replace("#{sid}", ticket.getWxsid());
           url = url.replace("#{uin}", ticket.getWxuin());
           url = url.replace("#{synckey}", urlEncode(syncKey));
    
           GetMethod getMethod = new GetMethod(url);
           if (httpClient.executeMethod(getMethod) == 200) {
               //此处一直输出window.synccheck={retcode:"1102",selector:"0"}
               log.info(getMethod.getResponseBodyAsString());
           }
    
       }
    
       public static String uuid() throws IOException {
           GetMethod getMethod = new GetMethod("https://login.wx.qq.com/jslogin?appid=wx782c26e4c19acffb&fun=new&lang=zh_CN");
    
           int i = httpClient.executeMethod(getMethod);
           if (i == 200) {
               return StringUtils.substringBetween(getMethod.getResponseBodyAsString(), "window.QRLogin.uuid = \"", "\";");
           }
           return null;
       }
    
       public static BufferedImage qrCodeImage(String uuid) throws IOException {
           GetMethod getMethod = new GetMethod("https://login.weixin.qq.com/qrcode/" + uuid);
           if (httpClient.executeMethod(getMethod) == 200) {
               return ImageIO.read(getMethod.getResponseBodyAsStream());
           }
           return null;
       }
    
       public static Map<String, String> waitScan(String uuid) throws IOException {
           GetMethod getMethod = new GetMethod("https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=" + uuid + "&tip=0");
           Map<String, String> result = Maps.newHashMap();
           if (httpClient.executeMethod(getMethod) == 200) {
               String response = getMethod.getResponseBodyAsString();
               if (response.startsWith("window.code=201;")) {
                   String userAvatar = StringUtils.substringBetween(response, "window.userAvatar = '", "';");
                   result.put("code", "201");
                   result.put("userAvatar", userAvatar);
               }
               if (response.startsWith("window.code=200;")) {
                   String redirectUri = StringUtils.substringBetween(response, "window.redirect_uri=\"", "\";");
                   result.put("code", "200");
                   result.put("redirectUri", redirectUri);
               }
               if (response.startsWith("window.code=408;")) {
                   result.put("code", "408");
               }
               if (response.startsWith("window.code=400;")) {
                   result.put("code", "400");
               }
           }
           return result;
       }
    
       public static AuthInfo ticket(String redirectUri) throws IOException {
           GetMethod getMethod = new GetMethod(redirectUri + "&fun=new&version=v2");
           if (httpClient.executeMethod(getMethod) == 200) {
               return AuthInfo.valueOf(getMethod.getResponseBodyAsString());
           }
           return null;
       }
    
       public static JSONObject init(AuthInfo authInfo) throws IOException {
           PostMethod postMethod = new PostMethod("https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?lang=zh_CN&pass_ticket=" + urlEncode(authInfo.getPassTicket()));
           JSONObject baseRequest = new JSONObject();
           baseRequest.put("Uin", authInfo.getWxuin());
           baseRequest.put("Sid", authInfo.getWxsid());
           baseRequest.put("Skey", authInfo.getSkey());
           baseRequest.put("DeviceID", randomDeviceID());
    
           JSONObject jsonObject = new JSONObject();
           jsonObject.put("BaseRequest", baseRequest);
    
           postMethod.setRequestEntity(new StringRequestEntity(jsonObject.toJSONString(), "application/json; charset=utf-8", "utf-8"));
    
           if (httpClient.executeMethod(postMethod) == 200) {
               return JSON.parseObject(postMethod.getResponseBodyAsString());
           }
           return null;
       }
    
       private static String randomDeviceID() {
           return "e" + RandomStringUtils.randomNumeric(15);
       }
    
       private static String downloadImage(BufferedImage image, String fileName) {
           try {
               File output = new File(TEMP_DIR, fileName);
               ImageIO.write(image, "jpg", output);
               log.info("下载图片：" + output.getAbsolutePath());
               return output.getAbsolutePath();
           } catch (IOException e) {
               e.printStackTrace();
           }
           return null;
       }
    
       private static String base64Image(String imgStr, String fileName) {
           try {
               imgStr = StringUtils.substringAfter(imgStr, "data:img/jpg;base64,");
               BASE64Decoder decoder = new BASE64Decoder();
               byte[] buf = decoder.decodeBuffer(imgStr);
               for (int i = 0; i < buf.length; ++i) {
                   if (buf[i] < 0) {
                       buf[i] += 256;
                   }
               }
               File file = new File(TEMP_DIR, fileName);
               OutputStream out = new FileOutputStream(file);
               out.write(buf);
               out.flush();
               out.close();
               log.info("下载图片：" + file.getAbsolutePath());
               return file.getAbsolutePath();
           } catch (IOException e) {
               e.printStackTrace();
           }
           return null;
       }
    
       private static String urlEncode(String content) {
           try {
               return URLEncoder.encode(content, "UTF-8");
           } catch (UnsupportedEncodingException e) {
               e.printStackTrace();
           }
           return null;
       }

   }
   ```

   其中几个类的代码

   ``` java
   package com.zhanjixun.weixin.frame;

   import javax.swing.*;

   /**
    * @author :zhanjixun
    * @date : 2018/10/19 23:59
    */
   public class ImageFrame extends JFrame {

       private final JLabel label;

       public ImageFrame(String imagePath) {
           setTitle("请扫描二维码");
           setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
           setSize(435, 450);
           setLocationRelativeTo(getOwner());
           setResizable(false);
           label = new JLabel();
           label.setHorizontalAlignment(JLabel.CENTER);
           label.setIcon(new ImageIcon(imagePath));
           add(label);
       }

       public void setImage(String imagePath) {
           label.setIcon(new ImageIcon(imagePath));
       }
   }
   ```

   ```
   package com.zhanjixun.weixin.domain;

   import com.alibaba.fastjson.JSON;
   import lombok.Data;
   import org.json.XML;

   /**
    * @author :zhanjixun
    * @date : 2018/10/21 12:32
    */
   @Data
   public class AuthInfo {

       private Integer ret;
       private String message;
       private String skey;
       private String wxsid;
       private String wxuin;
       private String passTicket;
       private Integer isGrayScale;

       public static AuthInfo valueOf(String text) {
           return JSON.parseObject(XML.toJSONObject(text).getJSONObject("error").toString(), AuthInfo.class);
       }

   }
   ```

   ​	代码中注释指出了问题所在，这份代码执行下来 最后那里输出一直是

   > window.synccheck={retcode:"1102",selector:"0"}

   ​	1102 是一个不正常的状态码，我猜大概是微信的发现这个http某些内容错误（比如参数，比如cookie）才返回这个，我所期待的正常的应该是0。

   ​	这个时候我就开始怀疑我有没有填错参数，URL等信息咯，看呀看，看了两三天，愣是没看出哪里有问题，对比了chrome F12抓包的network发现，没啥不一样呀，为什么它能正常返回我这代码不行呢？为什么？

   ​	于是在码云上找了一些开源的网页微信抓包代码来做对比，看到他们发的请求啊，参数啊，请求头，字符编码等等信息都是跟我一样的，但是他们的能发成功而我却还是不行，几近奔溃。

   > 参考的项目有
   >
   > wechat4j  [https://gitee.com/hotlcc/wechat4j](https://gitee.com/hotlcc/wechat4j)
   >
   > itchat4j     [https://github.com/yaphone/itchat4j](https://github.com/yaphone/itchat4j)

   ​	持续了一周时候，依然没有找到问题所在，虽然一直没有抓到那只bug，但是总有一种神奇的魅力在吸引着我去研究它。

   	在对比开源项目的时候，我把自己的代码迁移到他们项目里面运行，发现当使用commons-httpclient发http请求的时候 最后那个请求一直都是返回1102，我从来就想过可能会是使用的http框架的问题啊。因为wechat4j使用的是httpcomponents.httpclient，然后我尝试用这个框架改写一下我的代码，写的代码大概这样子：

   ```java
   package com.zhanjixun.weixin.test;

   import com.alibaba.fastjson.JSON;
   import com.alibaba.fastjson.JSONObject;
   import com.google.common.collect.Maps;
   import com.zhanjixun.weixin.domain.AuthInfo;
   import com.zhanjixun.weixin.frame.ImageFrame;
   import lombok.extern.log4j.Log4j;
   import org.apache.commons.lang3.RandomStringUtils;
   import org.apache.commons.lang3.StringUtils;
   import org.apache.http.HttpEntity;
   import org.apache.http.HttpResponse;
   import org.apache.http.client.CookieStore;
   import org.apache.http.client.HttpClient;
   import org.apache.http.client.methods.HttpGet;
   import org.apache.http.client.methods.HttpPost;
   import org.apache.http.entity.ContentType;
   import org.apache.http.entity.StringEntity;
   import org.apache.http.impl.client.BasicCookieStore;
   import org.apache.http.impl.client.HttpClients;
   import org.apache.http.util.EntityUtils;
   import sun.misc.BASE64Decoder;

   import javax.imageio.ImageIO;
   import java.awt.image.BufferedImage;
   import java.io.*;
   import java.net.URLEncoder;
   import java.util.Map;
   import java.util.stream.Collectors;

   /**
    * @author :zhanjixun
    * @date : 2018/10/25 8:43
    */
   @Log4j
   public class Demo3 {

       private static CookieStore cookieStore = new BasicCookieStore();

       private static HttpClient httpClient = HttpClients.custom().setDefaultCookieStore(cookieStore).build();

       private static final String TEMP_DIR = System.getProperty("java.io.tmpdir");

       public static void main(String[] args) throws IOException {
           String uuid = uuid();
           BufferedImage bufferedImage = qrCodeImage(uuid);

           ImageFrame imageFrame = new ImageFrame(downloadImage(bufferedImage, "QRCode.jpg"));
           imageFrame.setVisible(true);

           String redirectUri;
           while (true) {
               Map<String, String> waitScan = waitScan(uuid);
               if (waitScan.get("code").equals("200")) {
                   log.info("登录成功");
                   imageFrame.setVisible(false);
                   imageFrame.dispose();
                   redirectUri = waitScan.get("redirectUri");
                   break;
               }
               if (waitScan.get("code").equals("201")) {
                   log.info("请在手机端确认登录");
                   imageFrame.setImage(base64Image(waitScan.get("userAvatar"), "userAvatar.jpg"));
               }
               if (waitScan.get("code").equals("408")) {
                   continue;
               }
               if (waitScan.get("code").equals("400")) {
                   log.info("扫码超时");
                   System.exit(0);
               }
           }
           AuthInfo ticket = ticket(redirectUri);
           JSONObject initMap = init(ticket);
           log.info("欢迎：" + initMap.getJSONObject("User").getString("NickName"));

           String syncKey = initMap.getJSONObject("SyncKey").getJSONArray("List").stream().map(d -> (JSONObject) d).map(d -> d.getString("Key") + "_" + d.getString("Val")).collect(Collectors.joining("|"));
           String url = "https://webpush.wx.qq.com/cgi-bin/mmwebwx-bin/synccheck?skey=#{skey}&sid=#{sid}&uin=#{uin}&synckey=#{synckey}";
           url = url.replace("#{skey}", urlEncode(ticket.getSkey()));
           url = url.replace("#{sid}", ticket.getWxsid());
           url = url.replace("#{uin}", ticket.getWxuin());
           url = url.replace("#{synckey}", urlEncode(syncKey));

           HttpGet httpGet = new HttpGet(url);
           HttpResponse httpResponse = httpClient.execute(httpGet);
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               HttpEntity entity = httpResponse.getEntity();
               String response = EntityUtils.toString(entity, "utf-8");
               log.info(response);
           }
       }

       private static String uuid() throws IOException {
           HttpGet httpGet = new HttpGet("https://login.wx.qq.com/jslogin?appid=wx782c26e4c19acffb&fun=new&lang=zh_CN");
           HttpResponse httpResponse = httpClient.execute(httpGet);
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               HttpEntity entity = httpResponse.getEntity();
               String response = EntityUtils.toString(entity, "utf-8");
               return StringUtils.substringBetween(response, "window.QRLogin.uuid = \"", "\";");
           }
           return null;
       }

       private static BufferedImage qrCodeImage(String uuid) throws IOException {
           HttpGet httpGet = new HttpGet("https://login.weixin.qq.com/qrcode/" + uuid);
           HttpResponse httpResponse = httpClient.execute(httpGet);
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               return ImageIO.read(httpResponse.getEntity().getContent());
           }
           return null;
       }

       private static Map<String, String> waitScan(String uuid) throws IOException {
           HttpGet httpGet = new HttpGet("https://login.wx.qq.com/cgi-bin/mmwebwx-bin/login?loginicon=true&uuid=" + uuid + "&tip=0");
           HttpResponse httpResponse = httpClient.execute(httpGet);
           Map<String, String> result = Maps.newHashMap();
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               String response = EntityUtils.toString(httpResponse.getEntity(), "utf-8");
               if (response.startsWith("window.code=201;")) {
                   String userAvatar = StringUtils.substringBetween(response, "window.userAvatar = '", "';");
                   result.put("code", "201");
                   result.put("userAvatar", userAvatar);
               }
               if (response.startsWith("window.code=200;")) {
                   String redirectUri = StringUtils.substringBetween(response, "window.redirect_uri=\"", "\";");
                   result.put("code", "200");
                   result.put("redirectUri", redirectUri);
               }
               if (response.startsWith("window.code=408;")) {
                   result.put("code", "408");
               }
               if (response.startsWith("window.code=400;")) {
                   result.put("code", "400");
               }
           }
           return result;
       }

       public static AuthInfo ticket(String redirectUri) throws IOException {
           HttpGet getMethod = new HttpGet(redirectUri + "&fun=new&version=v2");
           HttpResponse httpResponse = httpClient.execute(getMethod);
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               return AuthInfo.valueOf(EntityUtils.toString(httpResponse.getEntity(), "utf-8"));
           }
           return null;
       }

       public static JSONObject init(AuthInfo authInfo) throws IOException {
           HttpPost postMethod = new HttpPost("https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?lang=zh_CN&pass_ticket=" + urlEncode(authInfo.getPassTicket()));

           JSONObject baseRequest = new JSONObject();
           baseRequest.put("Uin", authInfo.getWxuin());
           baseRequest.put("Sid", authInfo.getWxsid());
           baseRequest.put("Skey", authInfo.getSkey());
           baseRequest.put("DeviceID", randomDeviceID());

           JSONObject jsonObject = new JSONObject();
           jsonObject.put("BaseRequest", baseRequest);

           postMethod.setEntity(new StringEntity(jsonObject.toJSONString(), ContentType.APPLICATION_JSON));

           HttpResponse httpResponse = httpClient.execute(postMethod);
           if (httpResponse.getStatusLine().getStatusCode() == 200) {
               return JSON.parseObject(EntityUtils.toString(httpResponse.getEntity(), "utf-8"));
           }
           return null;
       }

       private static String randomDeviceID() {
           return "e" + RandomStringUtils.randomNumeric(15);
       }

       private static String downloadImage(BufferedImage image, String fileName) {
           try {
               File output = new File(TEMP_DIR, fileName);
               ImageIO.write(image, "jpg", output);
               log.info("下载图片：" + output.getAbsolutePath());
               return output.getAbsolutePath();
           } catch (IOException e) {
               e.printStackTrace();
           }
           return null;
       }

       private static String base64Image(String imgStr, String fileName) {
           try {
               imgStr = StringUtils.substringAfter(imgStr, "data:img/jpg;base64,");
               BASE64Decoder decoder = new BASE64Decoder();
               byte[] buf = decoder.decodeBuffer(imgStr);
               for (int i = 0; i < buf.length; ++i) {
                   if (buf[i] < 0) {
                       buf[i] += 256;
                   }
               }
               File file = new File(TEMP_DIR, fileName);
               OutputStream out = new FileOutputStream(file);
               out.write(buf);
               out.flush();
               out.close();
               log.info("下载图片：" + file.getAbsolutePath());
               return file.getAbsolutePath();
           } catch (IOException e) {
               e.printStackTrace();
           }
           return null;
       }

       private static String urlEncode(String content) {
           try {
               return URLEncoder.encode(content, "UTF-8");
           } catch (UnsupportedEncodingException e) {
               e.printStackTrace();
           }
           return null;
       }
   }
   ```

   然后就终于输出了

   > window.synccheck={retcode:"0",selector:"0"}

   ​	呜呜~~ 两份代码除了使用的http框架不同之外，完全一模一样的呀亲。

   ​	自此，这个bug已经进入到的框架里面了，我解决不了这个问题，但我解决了产生问题的代码啊。

   这个坑真深，所以以后就这么快乐的改用httpcomponents.httpclient框架啦

  

2018年10月25日 09:55:07

完。





2018年10月27日 12:02:18

找到问题所在，前五步获取的cookie有如下：

```
Cookie:$Version=0; mm_lang=zh_CN; $Path=/; $Domain=wx.qq.com
Cookie:$Version=0; webwx_data_ticket=gSc+3MmqcPzdjXEZQPOh7UPL; $Path=/; $Domain=.qq.com
Cookie:$Version=0; webwx_auth_ticket=CIsBEI+gyvEDGoAB9DUx1tbMSvdIkGuKm2tvyztTyiECaGrq294i2UszXTQdV0xt5J5V18fRE3KXrqWEhhubj/54mRQ+TrJUxvs7dtZkPuaXAfPiGdmUNXlj256DaAhn0SWJDA8h9SgQQ805+kfpfqIY4Vp13kqEfjdZ73+HiWwL9g0K/piKaBfeUBo=; $Path=/; $Domain=wx.qq.com
Cookie:$Version=0; wxuin=1187598722; $Path=/; $Domain=wx.qq.com
Cookie:$Version=0; wxloadtime=1540612517; $Path=/; $Domain=wx.qq.com
Cookie:$Version=0; wxsid=sQxW5E+NZkwIaO2w; $Path=/; $Domain=wx.qq.com
Cookie:$Version=0; webwxuvid=10fb263bfa2d6a4090315b470d96d1d886c1715ded460d1d6b25a075f9abcad75e8a5f75af3f695a09eb7341a4b68767; $Path=/; $Domain=wx.qq.com
```

在使用commons-httpclient的时候 发送最后那个请求，主机是webpush.wx.qq.com，这个框架只带了其中的一个cookie

```
Cookie:$Version=0; webwx_data_ticket=gSc+3MmqcPzdjXEZQPOh7UPL; $Path=/; $Domain=.qq.com
```

注意到domain。

而httpcomponents.httpclient把上面所有cookie都带上了，所有可以成功。
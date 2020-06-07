###  H5简易播放器说明

#### 技术栈

1. flv.js(1.5.0)
2. jquery(3.4.1)
3. flash (as3)
4. ffmpeg
5. node-media-server

### 文件目录结构

1. document     (as3 语法文档)
2. ffmpeg       (ffmpeg windows版本build exe)
3. flash        (flash 播放器源码,内部使用rtmp方式打开视频)
4. node_modules (npm 包文件)
5. public       (嵌入页面文件夹)
   --- index_h5.html (flv方式h5页面)
   --- index.html    (flash方式页面)
6. app.js       程序服务启动 app.js
7. config.js    程序配置文件

### 使用方法

1. npm i
2. 修改 `config.js` `public/index_h5.html(670行)`  配置文件
3. 运行 `node ./app.js`  (或者用nssm注册为服务)
4. 打开浏览器访问 `http://127.0.0.1:8000/admin` 可以管理媒体服务器地址
5. 打开浏览器访问 `http://127.0.0.1:80/index_h5.html` 为h5的播放页面

### 业务平台使用播放页面方法

1. 方法1:在需要打开视频的页面通过打开浏览器新Tab页面的方式打开视频即调用:
    ```js
    window.open('/public/index_h5.html?xxxxxx','_blank')
    ```
2. 方法2:在需要打开视频的页面通过嵌入ifream的方式进行调用 
    ```html
    <ifream src="/public/index_h5.html?xxxxxx"></ifream>
    ```
### 播放页面参数说明

key | 说明  |  备注  
-|-|-
channel|通道数|1,2,3,4
mediaurl|809企业视频地址|http://[ip]:[port]/[车牌号码].[车牌颜色].[逻辑通道号].[音视频标志(0:音视频,1:音频,2:视频)].[时效口令],该参数只获取逻辑通道1的即可，其他通道由当前页面进行计算,对该url进行参数编码
serverip|媒体服务器地址|部署服务器ip
httpport|请求rtmp前需要请求http端口,可以不传|默认12345
rtmpport|rtmp端口,可以不传|默认1935


### 注意事项

1. 保证外网访问的端口都可以访问,通过配置防火墙
3. 由于浏览器有并发下载限制，所以媒体服务默认配置了3组服务器满足18路视频并发.
4. 由于参数中有多个.导致参数解析问题,需要修改 node-media-server/node_flv_session.js  63行内 split('.')=>split('.flv')
5. 参考  https://github.com/illuspas/Node-Media-Server/blob/master/README_CN.md 

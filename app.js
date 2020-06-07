const NodeMediaServer = require('node-media-server');
const express = require('express');
const app = express();
const appConfig = require('./config');

//server
const config = {
    rtmp: {
        port: 1935,
        chunk_size: 60000,
        gop_cache: true,
        ping: 30,
        ping_timeout: 60
    },
    // http方式flv或websocket方式flv
    http: {
        port: appConfig.h5port1,
        allow_origin: '*'
    },
    // rtmp中继地址
    relay: {
        ffmpeg: 'ffmpeg/bin/ffmpeg.exe',
        tasks: [
            {
                app: 'live',
                mode: 'pull',
                edge: appConfig.rtmpedge,
            }
        ]
    }
};
// rtmp://58.200.131.2:1935/livetv/cctv1
// rtmp://58.200.131.2:1935/livetv/cctv2
// server node1
var nms1 = new NodeMediaServer(config)
nms1.run();
// server node2
var config2 = config;
config2.rtmp.port++;
config2.http.port = appConfig.h5port2;
var nms2 = new NodeMediaServer(config2);
nms2.run();
// server node3
var config3 = config2;
config3.rtmp.port++;
config3.http.port = appConfig.h5port3;
var nms3 = new NodeMediaServer(config3);
nms3.run();

// web
app.use(express.static('public'))
app.get('/', (req, res) => res.redirect('index.html'))
app.get('/live', (req, res) => res.json({ code: 200, msg: 'ok' }))
app.listen(appConfig.webport, () => console.info('Example app listening on port ' + appConfig.webport + '!'))
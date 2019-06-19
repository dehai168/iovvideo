const NodeMediaServer = require('node-media-server');
//可用rtmp地址
//香港财经,rtmp://202.69.69.180:443/webcast/bshdlive-pc
//韩国朝鲜日报: rtmp://live.chosun.gscdn.com/live/tvchosun1.stream
//美国1,rtmp://ns8.indexforce.com/home/mystream
//美国2,rtmp://media3.scctv.net/live/scctv_800
//美国中文电视,rtmp://media3.sinovision.net:1935/live/livestream
//湖南卫视,rtmp://58.200.131.2:1935/livetv/hunantv
const config = {
    rtmp: {
        port: 1935,
        chunk_size: 60000,
        gop_cache: true,
        ping: 30,
        ping_timeout: 60
    },
    http: {
        port: 8000,
        allow_origin: '*'
    },
    relay: {
        ffmpeg: 'ffmpeg/bin/ffmpeg.exe',
        tasks: [{
            app: 'iptv',
            mode: 'static',
            edge: 'rtmp://202.69.69.180:443/webcast/bshdlive-pc',
            name: 'hks'
        }, {
            app: 'mv',
            mode: 'static',
            edge: 'xhssf.mp4',
            name: 'dq'
        }
        ]
    }
};

var nms = new NodeMediaServer(config)
nms.run();
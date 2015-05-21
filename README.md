#XMIDI
###简介

>     XMIDI是一款IOS上的MIDI文件播放引擎，基于Audio Toolbox Framework和OpenAL这两个库。 	
>     XMIDI使用Audio Toolbox Framework下API来完成MIDI文件的读取和解析，然后使用OpenAL来播放对应的音符。
>     OpenAL播放声音时，对声音做了音量、立体声和渐隐处理，来模拟真实钢琴弹奏效果。
>     本引擎使用OC编写，项目示例为Swift语言。
>     使用上有问题可以联系我。
>     邮件:watarux@qq.com
>     QQ:56809958    
>     交流群:334533178

###视频演示
>[音效演示视频截这里](http://v.youku.com/v_show/id_XOTEzMTc0MTYw.html)

###Demo截图
>![AD](http://git.oschina.net/uploads/images/2015/0519/002136_1a65a0dc_21807.jpeg "AD")

###插播广告
>   给自己游戏做个宣传，欢迎大家下载
>![AD](http://git.oschina.net/uploads/images/2015/0519/002155_e5b0be86_21807.jpeg "AD")

###更新履历
####2015-05-18
>1. 更新至1.2版本。
2. 代码整合和优化，现在XMIDI所有代码都在XMidiLib目录下。
3. XMidiPlayer方法更新。

####2015-03-22
>1.增加播放控制。

####2015-03-18
>1.增加XMidiPlayer，现在播放MIDI文件更为方便。

####2015-03-17
>1.初次版本发布。

###使用方法
####1.初始化API
```javascript
    //初始化，会将音频加载到内存，如果资源释放后，再播放，需要重新初始化。
    XMidiPlayer.xInit()
```

####2.资源释放API
```javascript
    //资源释放，不必每次播放完都去释放资源，只有在你觉得需要时释放即可。
    XMidiPlayer.xDispose()
```

####3.播放MIDI示例
```javascript
    //读取文件
    var filePath = NSBundle.mainBundle().pathForResource("midiFileName", ofType: "mid")

    //根据URL播放MIDI
    var url = NSURL(fileURLWithPath: filePath!)
    var midiPlayer:XMidiPlayer = XMidiPlayer()
    midiPlayer.initMidi(url!)
    midiPlayer.play()

    //根据Data播放MIDI
    var data = NSFileManager.defaultManager().contentsAtPath(filePath!)
    var midiPlayer:XMidiPlayer = XMidiPlayer()
    midiPlayer.initMidiWithData(data)
    midiPlayer.play()
```

###4.XMidiPlayer播放控制API
```javascript
    //Midi总播放时间(秒)
    @property (nonatomic,readonly) double totalTime;
    //Midi当前播放时间点(秒)
    @property (nonatomic) double time;

    //初始化MIDI URL
    -(void)initMidi:(NSURL*)midiUrl;
    //初始化MIDI Data
    -(void)initMidiWithData:(NSData*)data;
    //暂停
    -(void)pause;
    //播放、继续播放
    -(void)play;
    //重播
    -(void)replay;
    //获取当前播放进度 返回一个0～1的一个小数，代表进度百分比
    -(double)getProgress;
    //设置当前播放进度 progress是一个0～1的一个小数，代表进度百分比
    -(void)setProgress:(double)progress;
    //关闭播放器
    -(void)closePlayer;
```

###5.XMidiPlayer委托事件
```javascript
    //播放进度变化 progress是一个0～1的一个小数，代表进度百分比
    + (void)progressChanged:(double)progress;
```
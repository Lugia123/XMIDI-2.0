#XMIDI
###简介

>     XMIDI是一款IOS上的MIDI文件播放引擎。 	
>     2.0版本与之前1.0相比最大的变化在于播放模式的变更，由原来的OpenAL改为了AudioUnit。
>     2.0版本支持多种乐器，可以自己定义和添加乐器。
>     本引擎使用OC编写，项目示例为Swift语言。
>     使用上有问题可以联系我。
>     邮件:watarux@qq.com
>     QQ:56809958    
>     交流群:334533178

###插播广告
>   给自己游戏做个宣传，欢迎大家下载
>![AD](http://git.oschina.net/uploads/images/2015/0519/002155_e5b0be86_21807.jpeg "AD")

###更新履历
####2015-05-22
>1.初次版本发布。

###使用方法
####1.初始化API
```javascript
    //初始化。
    XMidiPlayer.xInit()
```

####2.资源释放API
```javascript
    //资源释放。
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

###6.关于乐器音频



>     音频文件使用.aupreset文件，可以使用Apple的AU Lab生成。
>     可以在Xcode->Open Developer Tool->More Developer Tools中下载Audio Tools for Xcode。
> 
>     乐器有两级分类，第一级17个大类，第二级128个子类。
>     每个大类有一种默认乐器，然后每个子类对应一种乐器。
>     其实还可以再细分，有兴趣的朋友可以看这里https://en.wikipedia.org/wiki/General_MIDI_Level_2

###7.默认乐器


>     我添加的不全，缺少的大家可以自己添加，可在XAudioPlayer.h文件中修改乐器配置。
>     第一级
>     InstrumentFirstType_Piano “Yamaha Grand Piano”
>     InstrumentFirstType_ChromaticPercussion “Celesta”
>     InstrumentFirstType_Organ Full ”Organ“
>     InstrumentFirstType_Guitar “Classical Acoustic Guitar”
>     InstrumentFirstType_Bass “Muted Electric Bass”
>     InstrumentFirstType_OrchestraSolo “String Ensemble”
>     InstrumentFirstType_OrchestraEnsemble “String Ensemble”
>     InstrumentFirstType_Brass “French Horns”
>     InstrumentFirstType_Reed ”Alto Sax“
>     InstrumentFirstType_Wind “Flutes”
>     
>     第二级
>     InstrumentSecondType_OrchestralKit Orchestral Kit
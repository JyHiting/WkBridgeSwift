# WkBridgeSwift

## 说明

该框架不干扰项目中现有的 WkWebview 的使用方式可以和现有项目的方法挂载使用方式互存  
该框架提供的功能有：  
简化 WkWebview 和 Web 前端交互通信逻辑  
提供截长图功能  
帮助处理 body 丢失问题

## 安装

你可以通过 pod 安装

```ruby
pod 'WkBridgeSwift'
```

或者你可以直接使用源码

## 使用

导入模块：

```
import WkBridgeSwift
```

假设你项目中已经存在 wkwebview 实例，那么直接执行代码：

```ruby
bridge = WkWebJsBridge.bridgeFor(webView: wk)
```

## 注册 iOS 方法提供给 js 端使用

有时候我们只需要 js 端执行我们的一个操作，并不需要反馈也不需要入参那么就注册无参数无回调方法提供给 web 端调用

```
//注册无参数无回调方法提供给web端调用
bridge?.register(handler: "dotask1", doSomething: { [unowned self] in

})
```

有时候我们需要 js 端执行我们的一个操作且传给 iOS 端一些信息，那么就注册注册有参数无回调方法提供给 web 端调用

```
//注册有参数无回调方法提供给web端调用
bridge?.register(handler: "dotask2", doSomething: { [unowned self] (paras) in

})
```

有时候我们需要 js 端执行我们的一个操作且传给 iOS 端一些信息，并在 js 端得到一些反馈，那么注册有参数有回调方法提供给 web 端调用

```
//注册有参数有回调方法提供给web端调用
bridge?.register(handler: "dotask3", doSomething: { (paras, cb:WkBridgeResponseCallback?) in

})
```

## js 端注册方法提供给 iOS 端使用

有时候我们仅仅想在 js 端注册一些方法让 iOS 端去调用，那么就在 js 端注册注册无参数无回调服务

```
//注册无参数无回调服务
WkBridgeSwift.registerJsService('jsservice1', function () {

})
```

有时候我们想在 js 端注册一些方法让 iOS 端调用同时接受一些 iOS 端传入的信息，那么就在 js 端注册有参数无回调的服务

```
//注册有参数无回调
WkBridgeSwift.registerJsService('jsservice2', function (paras) {

})
```

有时候我们想在 js 端注册一些方法让 iOS 端调用同时接受一些 iOS 端传入的信息，且在 js 端处理完毕之后回调一些信息给 iOS 端的时候，那么就在 js 端注册有参数且需要回调的服务

```
WkBridgeSwift.registerJsService('jsservice3', function (paras, callback) {

})
```

## 截取长图

```
bridge?.takeSnapshot({ (img) in

})
```

## 作者

1575792978@qq.com

## License

WkBridgeSwift is available under the MIT license. See the LICENSE file for more info.

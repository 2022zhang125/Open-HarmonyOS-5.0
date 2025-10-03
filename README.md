# 仿Kazumi的原生鸿蒙开发

鸿蒙开发版本及其API版本

**<font color=red>*注：该项目只做学习，侵私删*</font>**

| API版本 | ohos版本 |
| ------- | -------- |
| 19      | 5.1.1    |

当前进度：

- 首页广告页
- 推荐页面
  - 动画详情
    - 概览页
    - 吐槽页
    - 角色页
    - 评论页
    - 制作人员
  - 搜索功能


---



##  以下是在学习过程中对知识的记录

> tips: 
>
> - 在画页面的时候，记得现在画图软件里面拉框。不然就会这边一个margin，那边一个padding。搞到最后盒子挤盒子
> - 不会的代码就看源码，然后去官方网站查询即可。
>   - 查UI组件：[应用开发导读-基础入门 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide)
>   - 查API：[ArkTS API-ArkUI（方舟UI框架）-应用框架 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkui-arkts)
>   - 这个大佬的网站更加友好但是有些还没更新 [前言 | 《ArkUI实战》](https://www.arkui.club/)

目录：

- [定时器删除](#定时器删除)
- [沉浸式全屏](#沉浸式全屏)
- [网络请求](#网络请求)
- [Loading页面](#Loading页面)
- [触底加载](#触底加载)
- [Grid布局](#Grid布局)
- [Navigation页面跳转](#Navigation页面跳转)

---



### 定时器删除

在使用定时器的时候记得关闭，不然的话就会鬼畜的。删除时记得给定时器的`number`值。

```ts
// Start组件被加载之后执行
  aboutToAppear(): void {
    this.stopNum = setInterval(() => {
      if (this.count > 0) {
        this.count--;
      } else {
        this.jumpToSecond();
      }
    }, 1000)
  }

  // 跳转页面并消除定时器
  jumpToSecond = (): void => {
    console.info("正在消除Interval定时器...")
    clearInterval(this.stopNum)
    this.pathStack.replacePathByName("Second", null, false)
  }
```



---



### 网络请求沉浸式全屏

> 沉浸式全屏的实现就是在`EnterAbility`中获取windows对象。然后调用 `setWindowLayoutFullScreen`全屏展示即可

```ts
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { enterImmersion } from './ImmersionAbility';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  // ...
  async onWindowStageCreate(windowStage: window.WindowStage){
   // 开启沉浸式全屏
    let windowClass:window.Window = await windowStage.getMainWindow()
    await enterImmersion(windowClass)
    // ...
  }
  // ...
}
```

> 具体实现以下 `enterImmersion()`方法

```ts
import window from '@ohos.window';

export async function enterImmersion(windowClass: window.Window) {
  // 获取状态栏和导航栏的高度
  windowClass.on("avoidAreaChange", (data: window.AvoidAreaOptions) => {
    if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
      // 将状态栏和导航栏的高度保存在AppStorage中
      AppStorage.setOrCreate<number>("topHeight", data.area.topRect.height);
      AppStorage.setOrCreate<number>("bottomHeight", data.area.bottomRect.height);
    }
  });
  // 设置窗口布局为沉浸式布局
  await windowClass.setWindowLayoutFullScreen(true)
  await windowClass.setWindowSystemBarEnable(["status", "navigation"])
  // 设置状态栏和导航栏的背景为透明
  await windowClass.setWindowSystemBarProperties({
    navigationBarColor: "#00000000",
    statusBarColor: "#00000000",
  })
}
```



---



### 网络请求

在此之前记得在模拟器中开启网络权限

```json
{
  "module": {
    // 添加获取网络的权限
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ],
    // ...
}
```



#### 第一步：发送请求(GET请求)

> 封装默认GET请求函数

```ts
function getRequest(url: string): Promise<http.HttpResponse> {
  // 构建GET请求
  const httpRequest = http.createHttp();
  return httpRequest.request(url, {
    method: http.RequestMethod.GET,
    readTimeout: 5000,
    header: {
      'Content-Type': 'application/json'
    },
    connectTimeout: 3000,
    extraData: {}
  });
}
```

> 发送请求

```ts
export async function HttpRequestGet(type: number, limit: number, offset: number): Promise<AnimeRecommendResponse> {
  const url = Const.RECOMMEND_SERVER_URL + `?type=${type}&limit=${limit}&offset=${offset}`
  try {
    const res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.error("请求失败:", JSON.stringify(error));
    throw new Error(error);
  }
}
```



#### 第二步：解析数据

> 对解析数据时返回的对象进行限制

```ts
function ParseResponseData<T extends AnimationResponse>(httpResult: http.HttpResponse): T {
  let resultData: T;
  if (typeof httpResult.result === 'string') {
    resultData = JSON.parse(httpResult.result) as T;
  } else {
    resultData = httpResult.result as T;
  }
  return resultData
}
```



---



### Loading页面

> 调用 `LoadingProgress`组件添加Loading状态，然后在每一次请求时加上状态控制即可。

```ts
@Component
export struct Loading{
  build() {
    Column() {
      LoadingProgress()
        .color(Color.Black)
        .width(80).height(80)
      Text('loading...')
        .fontSize(16)
        .fontColor(Color.Black)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7FAF1')
    .justifyContent(FlexAlign.Center)
  }
}
```



---



### 触底加载

> `onScrollEdge()` 这个函数可以触底时触发

```ts
Scroll(){
      if(this.isLoading){
        Loading()
      }else{
        GridRow({columns: {sm: 3, md: 3, lg: 3},gutter: {x: 2, y: 4}}) {
          ForEach(this.animations,(animation:AnimationItem,index:number)=>{
            AnimationUnitSkeleton({animationItem:animation})
          })
        }
      }
    }
    .scrollBar(BarState.Off)
    .onScrollEdge((side:Edge)=>{
       if(side === Edge.Bottom){
         // 发送请求，加载数据
        this.loadMoreData()
       }
    })
    .margin({top:13,bottom:50})
```



---



### Grid布局

> 使用网格布局对推荐页`Recommend`进行多行三列的实现。

```ts
GridRow({columns: {sm: 3, md: 3, lg: 3},gutter: {x: 2, y: 4}}) {
  ForEach(this.animations,(animation:AnimationItem,index:number)=>{
    AnimationUnitSkeleton({animationItem:animation})
  })
}
```

> `AnimationUnitSkeleton`

```ts
GridCol({span: 1}){
  // ...
}
```



---



### Navigation页面跳转

[Navigation文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-navigation-navigation)

#### 第一步：编写子页面（待跳转页面）

> 实现目标：点击 First页面 的 btn 跳转到 Second页面即可。

##### First页面

```ts
@Builder
export function FirstBuilder() {
  First();
}

@Component
struct First {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Button("点击跳转Second 页面").onClick(() => {
        // 向配置文件中name为Second的页面进行跳转
        console.info("正在跳转Second页面...")
        this.pathStack.pushPathByName("Second", null, false)
      })
    }
    // 在挂载后注册页面
    .onReady((content) => this.pathStack = content.pathStack)
    .title("First 页面")
  }
}
```



##### Second页面

```ts
@Builder
export function SecondBuilder(){
  Second();
}

@Component
struct Second {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination()
      .title("Second 页面")
      // 注册一下
      .onReady((content) => this.pathStack = content.pathStack)
  }
}
```



##### 主页面（Index页面）

```ts
@Entry
@Component
struct Index {
  // 主路由进行跳转First
  pathStack: NavPathStack = new NavPathStack();

  build() {
    // 这里一定要加上我们的路由参数
    Navigation(this.pathStack)
      .onAppear(() => {
        console.info("正在跳转First页面...")
        this.pathStack.pushPathByName("First", null, false)
      })
      // 隐藏返回功能，让用户不能返回到这个页面
      .hideNavBar(true)
  }
}
```



注意：

- 子页面
  - 使用 `NavDestination()` 组件并在 `onReady()`进行注册操作
  - 对外使用`@Builder`装饰器对当前组件进行暴露
- 主页面
  - 使用`Navigation()`组件并在`onAppear()`时进行跳转页面的操作
  - 使用`hideNavBar(true)`对返回箭头的隐藏



---



#### 第二步：编写配置文件

在`module.json5`中编写路由跳转相关的JSON文件

```json
{
  "module": {
    "routerMap": "$profile:router_map",
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone"
    ],
}
```

然后去编写该文件即可。

注意：其中的最大对象应为 `routerMap`别写错了。

```json
{
  "routerMap": [
    {
      "name": "First",
      "pageSourceFile": "src/main/ets/pages/First.ets",
      "buildFunction": "FirstBuild"
    },
    {
      "name": "Second",
      "pageSourceFile": "src/main/ets/pages/Second.ets",
      "buildFunction": "SecondBuild"
    }
  ]
}
```

OK，以上就完成了路由跳转。

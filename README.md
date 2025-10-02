# Navigation页面跳转
[Navigation文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-navigation-navigation)

## 第一步：编写子页面（待跳转页面）

> 实现目标：点击 First页面 的 btn 跳转到 Second页面即可。

### First页面

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



### Second页面

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



### 主页面（Index页面）

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



## 第二步：编写配置文件

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
  	// ....
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

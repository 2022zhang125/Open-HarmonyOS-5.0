@Builder
export function FirstBuild() {
  First();
}

@Component
struct First {
  pathStack: NavPathStack = new NavPathStack()
  @StorageLink("topHeight") topHeight: number = 0
  @State count: number = 5
  @State stopNum: number = 0

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
    this.pathStack.replacePathByName("Home", null, false)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r('app.media.ad'))
          .onClick(() => {

          })
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        Button(`${this.count}秒 跳过`)
          .backgroundColor('#c1c1c1c1')
          .margin({top:px2vp(this.topHeight),right:15})
          .onClick(() => {
            this.jumpToSecond();
          })
      }
    }
    // 在挂载后注册页面
    .onReady((content) => {
      this.pathStack = content.pathStack
    })
  }
}
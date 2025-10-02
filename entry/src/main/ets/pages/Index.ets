@Entry
@Component
struct Index {
  // 主路由进行跳转First
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack)
      .onAppear(() => {
        console.info("正在跳转First页面...")
        this.pathStack.pushPathByName("First", null, false)
      })
      // 隐藏返回功能，让用户不能返回到这个页面
      .hideNavBar(true)
  }
}
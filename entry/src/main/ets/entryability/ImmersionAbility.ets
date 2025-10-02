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

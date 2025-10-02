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
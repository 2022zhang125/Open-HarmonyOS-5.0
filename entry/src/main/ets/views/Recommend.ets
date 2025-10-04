import { AvatarUtil } from "../common/AvatarUtil";
import { DefaultContent } from "../recommendpages/DefaultContent";
import { GeneralContent } from "../recommendpages/GeneralContent";

@Component
  // 推荐页面
export struct Recommend {
  @State topIndex: number = -1
  @State topNameList: Array<string> =
    ['日常', '原创', '校园', '搞笑', '奇幻', '百合', '恋爱', '悬疑', '热血', '后宫', '机战', '轻改', '偶像'
      , '治愈', '异世界'];
  @State isClicked: boolean = false
  @Consume('pathStack') pathStack?: NavPathStack
  scroll: Scroller = new Scroller()

  @Builder
  topBuilder(title: string, index: number) {
    Stack() {
      Button(title)
        .padding(5)
        .width(80)
        .height(40)
        .onClick(() => {
          console.info("index = " + index + " topIndex = " + this.topIndex)
          if (index === this.topIndex) {
            this.topIndex = -1
          } else {
            this.topIndex = index
          }
        })
        .margin(5)
        .fontColor(index !== this.topIndex ? Color.Black : Color.White)
        .backgroundColor(index === this.topIndex ? "#ff296a34" : "#ffd1e8cd") // 41,106,52  209,232,205
    }
  }

  @StorageLink("topHeight") topHeight: number = 0
  @StorageLink("bottomHeight") bottomHeight: number = 0

  build() {
    Column() {
      Column() {

        // 左边头像 右边搜索
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Stack() {
            AvatarUtil({ src: $r("app.media.logo"), avatarSize: 60 }).margin(8)
          }

          Button({ type: ButtonType.Circle, stateEffect: false }) {
            // 搜索
            AvatarUtil({ src: $r("app.media.search"), avatarSize: 30 }).margin(8)
          }.backgroundColor("#F8FBF2").onClick(() => {
            this.pathStack?.pushPathByName("Search", null, false)
          })
        }
        .width("100%")
        .margin({ top: px2vp(this.topHeight) })
      }

      Column() {
        // 导航栏
        Tabs({ barPosition: BarPosition.Start, index: this.topIndex }) {
          ForEach(this.topNameList, (item: string, index) => {
            TabContent() {
              Column() {
                Image($r('app.media.top'))
                  .width(60)
                  .height(60)
                  .backgroundColor("#AEF2AF")
                  .zIndex(2)
                  .padding(15)
                  .borderRadius(20)
                  .position({ x: '80%', y: '72%' })
                  .onClick(() => {
                    this.scroll
                      .scrollTo({
                        xOffset: 0, yOffset: 0, animation: {
                          duration: 300
                        }
                      })
                  })
                // 默认状态
                if (this.topIndex === index) {
                  GeneralContent({ title: item, index: this.topIndex, scroll: this.scroll })
                } else {
                  DefaultContent({ scroll: this.scroll })
                }
              }
            }
            .tabBar(this.topBuilder(item, index))
          }, (key: string) => key)
        }
        .onChange((val) => {
          console.info("切换：val = " + val)
          if (this.topIndex != -1) {
            this.topIndex = val
          }
        })
        // 禁用滚动功能
        .scrollable(false)
        .barMode(BarMode.Scrollable)
      }
    }
  }
}
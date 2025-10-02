import { Recommend } from "../views/Recommend";

@Builder
export function SecondBuild() {
  Second();
}
/**
 * 菜单名，菜单默认icon，菜单被选中icon
 */
interface tabBarsInterfaces {
  name: string,
  normal_icon: Resource,
  selected_icon: Resource,
}


@Component
struct Second {
  @State currentIndex:number = 0
  @Provide('pathStack') pathStack:NavPathStack = new NavPathStack()
  tabBars: Array<tabBarsInterfaces> = [
  {
    name: "推荐",
    normal_icon: $r('app.media.tuijian'),
    selected_icon: $r('app.media.tuijian_selected'),
  },
  {
    name: "时间表",
    normal_icon: $r('app.media.zhuifan'),
    selected_icon: $r('app.media.zhuifan_selected'),
  },
  {
    name: "追番",
    normal_icon: $r('app.media.like'),
    selected_icon: $r('app.media.like_selected'),
  },
  {
    name: "我的",
    normal_icon: $r('app.media.my'),
    selected_icon: $r('app.media.my_selected'),
  },
]
  @Builder tabBuilder(title:string,index:number,image:Resource,imaged:Resource){
    Column(){
      Stack(){
        if(this.currentIndex === index){
          Button(){
            Image(this.currentIndex === index ? imaged : image)
              .size({width:25,height:25})
          }
          .margin({top:40})
          .width(80)
          .height(40)
          .backgroundColor("#ffd1e8cd") // 209,232,205
        }else{
          Image(this.currentIndex === index ? imaged : image)
            .size({width:25,height:25})
            .margin({top:40})
        }
      }
      .height(30)
      Text(title).margin({top:30})
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }
  @Builder tabContentBuilder(index:number){
    if(index === 0){
      Recommend()
    }
  }
  build() {
    NavDestination() {
      // 底部菜单栏
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(this.tabBars,(item:tabBarsInterfaces,index)=>{
          TabContent(){
            this.tabContentBuilder(index)
          }
          .tabBar(this.tabBuilder(item.name,index,item.normal_icon,item.selected_icon))
        })
      }
      // 禁用左右滑动
      .scrollable(false)
      .barWidth('100%')
      .barHeight('9.8%')
      .barBackgroundColor("#ffecefe6") // 236,239,230
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .backgroundColor("#fff8fbf2") // 248,251,242
      .onChange((value)=>{
        this.currentIndex = value
      })
    }
    // 注册一下
    .onReady((content) => this.pathStack = content.pathStack)
    .hideBackButton(true)
  }
}
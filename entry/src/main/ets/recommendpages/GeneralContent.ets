import { AnimationUnitSkeleton } from "../common/AnimationUnitSkeleton";
import { Loading } from "../common/Loading";
import {
  BuildBody,
  getAnimationItemBySearch,
  getRank,
  transformSearchDataResponseToAnimations,
} from "../utils/HttpUtil";
import { AnimationItem } from "./DefaultContent";

@Component
export struct GeneralContent {
  @Prop title: string = "";
  @Prop index: number;
  @State isLoading: boolean = true
  @State animations: AnimationItem[] = []

  loadData() {
    // 构建Body
    const body = BuildBody("", "rank", [this.title], getRank())
    getAnimationItemBySearch(body, 100, 0).then(res => {
      this.animations = transformSearchDataResponseToAnimations(res, this.animations)
    })
  }

  // 发送请求获取数据
  aboutToAppear(): void {
    this.loadData()
    this.isLoading = false
  }

  build() {
    if (this.isLoading) {
      Loading()
    } else {
      // 展示页面
      Scroll() {
        GridRow({ columns: { sm: 3, md: 3, lg: 3 }, gutter: { x: 2, y: 4 } }) {
          ForEach(this.animations, (animation: AnimationItem) => {
            AnimationUnitSkeleton({ animationItem: animation })
          })
        }
      }
      .scrollBar(BarState.Off)
      .onScrollEdge((side) => {
        if (side === Edge.Bottom) {
          // 加载更多
          this.loadData()
        }
      })
    }
  }
}
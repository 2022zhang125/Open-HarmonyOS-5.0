import { AnimationUnitSkeleton } from "../common/AnimationUnitSkeleton";
import { Loading } from "../common/Loading";
import { HttpRequestGet, transformToAnimations } from "../utils/HttpUtil";

export interface AnimationItem {
  id: number;
  title: string;
  image: string | Resource;
}

export interface AImageInterface {
  large: string;
  common: string;
  medium: string;
  small: string;
  grid: string;
}

interface Rating {
  score: number;
  rank: number;
  count: number[];
  total: number;
}

interface Subject {
  id: number;
  name: string;
  nameCN: string;
  type: number;
  rating: Rating;
  locked: boolean;
  nsfw: boolean;
  images: AImageInterface;
}

interface data {
  subject: Subject;
  count: number;
}

export interface AnimationResponse {}

export interface AnimeRecommendResponse extends AnimationResponse {
  data: Array<data>;
  total: number;
}

@Component
export struct DefaultContent {
  scroll: Scroller = new Scroller()
  @State animations: AnimationItem[] = [];
  @State currentScrollHeight: number = 0;
  @State loadOffset: number = 0;
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    // 发送请求
    try {
      const response: AnimeRecommendResponse = await HttpRequestGet(2, 24, 0);
      // 关闭加载动画
      this.isLoading = false

      // 将API数据转换为Animation数组
      this.animations = transformToAnimations(response);
    } catch (error) {
      console.error('请求失败:', error);
    }
  }

  async loadMoreData(): Promise<void> {
    try {
      this.loadOffset += 24
      const response: AnimeRecommendResponse = await HttpRequestGet(2, 24, this.loadOffset);

      transformToAnimations(response).forEach((animation: AnimationItem) => {
        // 将新增的Animation添加到原数组中
        this.animations.push(animation)
      })
    } catch (error) {
      console.error('请求失败:', error);
    }
  }



  build() {
    Scroll(this.scroll) {
      if (this.isLoading) {
        Loading()
      } else {
        GridRow({ columns: { sm: 3, md: 3, lg: 3 }, gutter: { x: 2, y: 4 } }) {
          ForEach(this.animations, (animation: AnimationItem, index: number) => {
            AnimationUnitSkeleton({ animationItem: animation })
          })
        }
      }
    }
    .scrollBar(BarState.Off)
    .onScrollEdge((side: Edge) => {
      if (side === Edge.Bottom) {
        // 发送请求，加载数据
        this.loadMoreData()
      }
    })
    .margin({ top: 13, bottom: 50 })
  }
}

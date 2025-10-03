import { AnimationUnitSkeleton } from "../common/AnimationUnitSkeleton";
import { Loading } from "../common/Loading";
import { HttpRequestGet } from "../utils/HttpUtil";

export interface AnimationItem {
  id:number;
  title: string;
  image: string;
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
interface data{
  subject: Subject;
  count: number;
}
export interface AnimationResponse{}
export interface AnimeRecommendResponse extends AnimationResponse{
  data: Array<data>;
  total: number;
}
@Component
export struct DefaultContent{
  @Builder
  loadPage(){
    Column(){
      LoadingProgress()
        .color(Color.White)
        .width(80)
        .height(80)
      Text('Loading...')
        .fontSize(16)
        .fontColor(Color.White)
    }
  }
  scroll:Scroller = new Scroller()
  @State animations: AnimationItem[] = [];
  @State currentScrollHeight:number = 0;
  @State loadOffset:number = 0;
  @State isLoading:boolean = true;

  async aboutToAppear(): Promise<void> {
    // 发送请求
    try {
      const response: AnimeRecommendResponse = await HttpRequestGet(2,24,0);
      // 关闭加载动画
      this.isLoading = false

      // 将API数据转换为Animation数组
      this.animations = this.transformToAnimations(response);
    } catch (error) {
      console.error('请求失败:', error);
    }
  }
  async loadMoreData(): Promise<void>{
    try {
      this.loadOffset += 24
      const response: AnimeRecommendResponse = await HttpRequestGet(2,24,this.loadOffset);

      this.transformToAnimations(response).forEach((animation:AnimationItem)=>{
        // 将新增的Animation添加到原数组中
        this.animations.push(animation)
      })
    } catch (error) {
      console.error('请求失败:', error);
    }
  }
  transformToAnimations(response: AnimeRecommendResponse): AnimationItem[] {
    const result:Array<AnimationItem> = []
    for (let index = 0; index < response.data.length; index++) {
      const element = response.data[index];
      result.push({
        id:element.subject.id,
        title:element.subject.nameCN,
        image:element.subject.images.large
      })
    }
    return result;
  }

  build() {
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
  }
}

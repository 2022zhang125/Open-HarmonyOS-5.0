import { AnimationItem } from '../recommendpages/DefaultContent'

@Component
export struct AnimationUnitSkeleton{
  @Prop animationItem: AnimationItem;
  @State opacityValue: number = 0.5;
  @State imageLoaded: boolean = false;
  @State imageError: boolean = false;
  @State defaultImage:Resource = $r("app.media.defaultImage")
  @Consume('pathStack') pathStack?:NavPathStack

  onImageLoad() {
    this.imageLoaded = true;
    this.imageError = false;
  }

  onImageError() {
    this.imageLoaded = false;
    this.imageError = true;
  }

  build() {
    GridCol({span: 1}){
      Column(){
        Stack() {
          Image(this.defaultImage)
            .width('100%')
            .height(180)
            .borderRadius(15)
            .objectFit(ImageFit.Cover)

          Image(this.animationItem.image)
            .width('100%')
            .height(180)
            .borderRadius(15)
            .objectFit(ImageFit.Cover)
            .visibility(this.imageLoaded && !this.imageError ? Visibility.Visible : Visibility.Hidden)
            .onComplete(()=>{
              this.onImageLoad()
            })
            .onError(()=>{
              this.onImageError()
            })
            // 跳转至详情页面
            .onClick(()=>{
              console.info("页面被点击...")
              // 处理点击事件 跳转详情页
              this.pathStack?.pushPathByName("AnimationDetail",this.animationItem,false)
            })
        }
        .width('100%')
        .height(180)

        Text(this.animationItem.title)
          .width('100%')
          .fontSize(14)
          .letterSpacing(1)
          .fontWeight(FontWeight.Bold)
          .height(40)
          .maxLines(2)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('93%')
      .height(220)
      .borderRadius(15)
      .backgroundColor('#fff1f5eb')
    }
    .borderRadius(15)
  }
}

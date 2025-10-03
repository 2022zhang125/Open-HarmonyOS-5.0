import { AnimationUnitSkeleton } from "../common/AnimationUnitSkeleton"
import { AvatarUtil } from "../common/AvatarUtil"
import { InfoBox, Tag, Rating, Collection } from "../pages/AnimationDetail";
import { AImageInterface, AnimationItem, AnimationResponse } from "../recommendpages/DefaultContent"
import { getAnimationItemBySearch } from "../utils/HttpUtil";
import { Loading } from "../common/Loading";

export interface SearchDataResponse extends AnimationResponse {
  data: Array<Data>;
  total: number;
  limit: number;
  offset: number;
}

interface Data {
  date: string | null;
  platform: string;
  images: AImageInterface;
  image: string;
  summary: string;
  name: string;
  name_cn: string;
  tags: Array<Tag>;
  infobox: Array<InfoBox>;
  rating: Rating;
  collection: Collection;
  id: number;
  eps: number;
  meta_tags: Array<string>;
  volumes: number;
  series: boolean;
  locked: boolean;
  nsfw: boolean;
  type: number;
}

interface Body {
  "keyword": string,
  "sort": string,
  "filter": FilterInterface
}

interface FilterInterface {
  "type": Array<number>,
  "tag": Array<string>,
  "rank": Array<string>,
  "nsfw": boolean
}

@Builder
export function SearchBuild() {
  SearchPage()
}

@Component
struct SearchPage {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()
  @StorageLink("topHeight") topHeight: number = 0
  @State animations: AnimationItem[] = [];
  @State isLoading: boolean = false
  @State searchLimit: number = 20
  @State searchOffset: number = 0
  @State userInfo: string = ''

  BuildBody(data: string) {
    const body: Body = {
      "keyword": `${data}`,
      // 先默认为heat
      "sort": "heat",
      "filter": {
        "type": [
          2
        ],
        "tag": [],
        "rank": [
          ">=0",
          "<=99999"
        ],
        "nsfw": false
      }
    }
    return body
  }

  @Builder
  SortWay() {
    Row({ space: 10 }) {
      Image($r('app.media.sort'))
        .width(15)
        .height(15)
      Text("排序方式")
        .fontColor(Color.Black)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(130)
    .height(60)
    .borderRadius(20)
    .backgroundColor("#AEF2AF")
    .position({ x: 240, y: 760 })
    .zIndex(2)
  }

  build() {
    NavDestination() {
      Column() {
        this.SortWay()
        // 返回
        Row() {
          Button({ type: ButtonType.Capsule }) {
            AvatarUtil({
              src: $r('app.media.back')
            , avatarSize: 28
            })
          }
          .backgroundColor($r('app.color.background_color'))

          Text("搜索")
            .fontSize(24)
            .margin({ left: 35 })
        }.width('100%')
        .margin({ left: 20, top: px2vp(this.topHeight) + 18 })

        // input搜索框
        Column() {
          Search()
            .borderRadius('10%')
            .backgroundColor("#E5E9DF")
            .height('100%')
            .onSubmit((data) => {
              this.isLoading = true
              this.userInfo = data
              console.info("用户输入：" + data)
              // 发送Search请求
              getAnimationItemBySearch(this.BuildBody(this.userInfo), this.searchLimit, this.searchOffset)
                .then((res) => {
                  // 再次请求时，初始化
                  this.animations = []
                  res.data.forEach(item => {
                    const animation: AnimationItem = {
                      id: item.id,
                      title: item.name_cn ? item.name_cn : item.name,
                      image: item.image
                    }
                    this.animations.push(animation)
                  })
                })
              this.isLoading = false
            })
        }.height(58).margin({ left: 10, right: 10, top: 10 })

        // 内容
        Column() {
          if (this.isLoading) {
            Loading()
          } else {
            Scroll() {
              GridRow({ columns: { sm: 3, md: 3, lg: 3 }, gutter: { x: 2, y: 4 } }) {
                ForEach(this.animations, (animation: AnimationItem, index: number) => {
                  AnimationUnitSkeleton({ animationItem: animation })
                })
              }
            }.onScrollEdge((side) => {
              if (side === Edge.Bottom) {
                // 继续加载
                getAnimationItemBySearch(this.BuildBody(this.userInfo), this.searchLimit,
                  this.searchOffset += 20).then(res => {
                  res.data.forEach(item => {
                    const animation: AnimationItem = {
                      id: item.id,
                      title: item.name_cn ? item.name_cn : item.name,
                      image: item.image
                    }
                    this.animations.push(animation)
                  })
                })
              }
            })
          }
        }.margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background_color'))
    // 隐藏返回键，自定义即可
    .hideTitleBar(true)
    .onReady((content) => {
      this.pathStack = content.pathStack
    })
  }
}
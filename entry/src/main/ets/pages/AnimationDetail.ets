import { Loading } from "../common/Loading"
import { AnimationItem, AnimationResponse } from "../recommendpages/DefaultContent"
import { getAnimationComments, getAnimationItemInfo } from "../utils/HttpUtil"
import { LengthMetrics } from "@kit.ArkUI"
import { Comment, TuCao } from "./details/TuCao"
import { Role } from "./details/Role"
import { Marker } from "./details/Marker"

@Builder
export function AnimationDetailBuild() {
  AnimationDetail()
}

export interface Collection {
  collect: number,
  doing: number,
  dropped: number,
  on_hold: number,
  wish: number
}

interface Images {
  common: string,
  grid: string,
  large: string | Resource,
  medium: string,
  small: string
}

export interface InfoBox {
  key: string,
  value: string | Array<string>
}

export interface Rating {
  count: Record<number, number>,
  rank: number,
  score: number,
  total: number
}

export interface Tag {
  name: string,
  count: number,
  total_cont: number
}

export interface AnimationDetailResponse extends AnimationResponse {
  collection: Collection,
  date: string,
  eps: number,
  id: number,
  images: Images
  infobox: Array<InfoBox>,
  locked: boolean,
  meta_tags: Array<string>,
  name: string,
  name_cn: string,
  nsfw: boolean,
  platform: string,
  rating: Rating,
  series: boolean,
  summary: string,
  tags: Array<Tag>,
  total_episodes: number,
  type: number,
  volumes: number
}

// Home -> Recommend -> DefaultContent -> AnimationUnitSkeleton -> AnimationDetail(每个对象的id -> 发送请求即可)
@Component
struct AnimationDetail {
  @State animationItemParm: AnimationItem = {} as AnimationItem
  // 初始化
  @State animationInfo: AnimationDetailResponse = {} as AnimationDetailResponse;
  @State isLoading: boolean = true
  @State tabBarList: Array<string> = ['概览', '吐槽', '角色', '评论', '制作人员']
  @State currentIndex: number = 0;
  @State yOffsetSum: number = 0;
  @State opacitySum: number = 1;
  @State xOffset: number = 0;
  @State indicatorX: number = 28;
  @State maxLines: number = 6;
  @State isSticky: boolean = false;
  @State summaryExpanded: boolean = false;
  @State isShow: boolean = true
  @State loadMoreTitle: string = "加载更多"
  private readonly TOP_IMAGE_HEIGHT = 380;
  private readonly SCROLL_THRESHOLD = 300;
  scroller: Scroller = new Scroller()
  @State maxTags: number = 12
  // TuCao子组件加载数据
  @State offsetComment: number = 0;
  @State limitComment: number = 20;
  @State moreComments: Array<Comment> = [];

  updateIndicator(index: number): void {
    let x: number;
    if (index === 0) {
      x = 28;
    } else if (index > 0 && index < 4) {
      x = 30 * index + 28 + 32 * index;
    } else {
      x = 30 * index + 28 + 35 * index;
    }
    this.indicatorX = x;
  }

  pathStack: NavPathStack = new NavPathStack()
  @StorageLink('topHeight') topHeight: number = 0;

  resetScrollState() {
    this.yOffsetSum = 0;
    this.opacitySum = 1;
    this.isSticky = false;
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
  }

  @Builder
  OverView() {
    Column() {
      // 简介区域
      Column({ space: 15 }) {
        Text("简介")
          .fontSize(20)
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(this.animationInfo.summary)
          .maxLines(this.summaryExpanded ? -1 : 6)
          .fontSize(15)
          .letterSpacing(1)
          .lineSpacing(LengthMetrics.vp(7))
          .key(`summary-${this.summaryExpanded}`)

        Text(this.summaryExpanded ? "加载更少" : "加载更多")
          .fontColor("#427450")
          .width('100%')
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.summaryExpanded = !this.summaryExpanded
            if (!this.summaryExpanded) {
              this.resetScrollState()
            }
          }
          )
      }
      .alignItems(HorizontalAlign.Start)
      .margin(10)

      Column({ space: 15 }) {
        Text("标签")
          .fontSize(20)
          .textAlign(TextAlign.Start)
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {

          ForEach(this.animationInfo.tags.slice(0, this.maxTags), (item: Tag) => {
            Button() {
              Text() {
                Span(item.name + " ")
                  .fontColor(Color.Black)
                Span(item.count.toString())
                  .fontColor('#48694B')
              }
              .padding({
                top: 10,
                bottom: 10,
                left: 20,
                right: 20
              })
              .fontWeight(FontWeight.Bold)
              .fontSize(15)
            }
            .fontSize(15)
            .backgroundColor('#F8FBF2')
            .fontColor(Color.Black)
            .borderWidth(1)
            .borderColor("#D2D5CC")
            .borderRadius(8)
            .margin({ right: 8, bottom: 8 })
          }, (item: Tag) => item.name)

          if (this.animationInfo.tags && this.animationInfo.tags.length > this.maxTags) {
            Button() {
              Text('更多 +')
                .fontSize(15)
                .fontColor("#48694B")
            }
            .fontWeight(FontWeight.Bold)
            .fontSize(15)
            .padding({
              top: 10,
              bottom: 10,
              left: 20,
              right: 20
            })
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#F8FBF2')
            .fontColor(Color.Black)
            .borderWidth(1)
            .borderColor("#D1D4CB")
            .borderRadius(8)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.maxTags = this.animationInfo.tags.length
            })
          }
        }
        .width('100%')
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .margin({
        bottom: this.maxTags > 12 ? 35 : 160,
        left: 10,
        right: 10,
        top: 10
      })
    }
  }

  @Builder
  TuCao() {
    TuCao({
      animationItemParm: this.animationItemParm,
      offsetComment: this.offsetComment,
      limitComment: this.limitComment,
      moreComments: this.moreComments
    })
  }

  @Builder
  Role() {
    Role({ animationItemParm: this.animationItemParm })
  }

  @Builder
  Comment() {
    Column() {
      Text("未施工")
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Marker() {
    Marker({ animationItemParm: this.animationItemParm })
  }

  @Builder
  HeaderComponent(headerHeight:
  number | string, headerBackgroundColor:
    string, isSticky:
    boolean
  ) {
    Column() {
      Row() {
        ForEach(this.tabBarList, (item: string, index: number) => {
          Text(item)
            .fontColor(this.currentIndex === index ? "#296A34" : "#888888")
            .fontSize(16)
            .padding({
              left: 15,
              right: 15,
              top: 5,
              bottom: 5
            })
            .onClick(() => {
              if (this.currentIndex !== index) {
                this.resetScrollState();
                this.updateIndicator(index)
                this.currentIndex = index;
              }
            })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
        }, (item: string) => item)
      }
      .margin({ left: 20 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Stack() {
        Rect()
          .position({ x: -5 })
          .width(35)
          .height(2)
          .fill("#296A34")
          .radius(10)
          .translate({ x: this.indicatorX })
          .animation({
            duration: 150,
            curve: Curve.FastOutSlowIn
          })
      }
      .margin({ top: 5 })
      .height(2)
      .width('100%')
    }
    .height(headerHeight)
    .backgroundColor(headerBackgroundColor)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
    .position({ x: 0, y: 0 })
  }

  @Builder
  Header(headerHeight:
  number | string, headerBackgroundColor:
    string
  ) {
    Column() {
      Row() {
        ForEach(this.tabBarList, (item: string, index: number) => {
          Text(item)
            .fontColor(this.currentIndex === index ? "#296A34" : "#888888")
            .fontSize(16)
            .padding({
              left: 15,
              right: 15,
              top: 5,
              bottom: 5
            })
            .onClick(() => {
              if (this.currentIndex !== index) {
                this.resetScrollState(); // 非吸顶 Tab 切换时重置
                this.updateIndicator(index)
                this.currentIndex = index;
              }
            })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
        }, (item: string) => item)
      }
      .margin({ left: 20 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Stack() {
        Rect()
          .position({ x: -5 })
          .width(35)
          .height(2)
          .fill("#296A34")
          .radius(10)
          .translate({ x: this.indicatorX })
          .animation({
            duration: 150,
            curve: Curve.FastOutSlowIn
          })
      }
      .margin({ top: 5 })
      .height(2)
      .width('100%')
    }
    .height(headerHeight)
    .backgroundColor(headerBackgroundColor)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
  }

  @
  Builder
  StartWatching() {
    Row({ space: 10 }) {
      Image($r('app.media.start'))
        .width(15)
        .height(15)
      Text("开始观看")
        .fontColor(Color.Black)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(130)
    .height(55)
    .borderRadius(20)
    .backgroundColor("#AEF2AF")
    .position({ x: 250, y: 760 })
    .zIndex(2)
  }

  @
  Builder
  TitleHeader() {
    Row() {
      Row() {
        Image($r('app.media.back')).width(25).height(25).margin({ left: 10 })
          .onClick(async () => {
            this.pathStack.pop()
          })
        if (this.isSticky) {
          Row() {
            Text(this.animationInfo.name_cn)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(23)
              .width(180)
              .margin({ left: 10 })
              .height(30)
            // 爱心
            Image($r("app.media.empty_heard"))
              .margin({ left: 50 })
              .size({ width: 25, height: 25 })
          }
          .justifyContent(FlexAlign.SpaceAround)
        } else {
          Row() {
            Blank()
          }
        }
        Image($r("app.media.upload"))
          .width(23)
          .height(23)
          .margin({ right: 20 })
      }
      .margin({ top: 20, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .width('100%')
    .zIndex(8)
    .position({ x: 0, y: px2vp(this.topHeight) })
  }

  build() {
    NavDestination() {
      // back
      if (this.isLoading) {
        Loading()
      } else {
        Stack() {
          this.TitleHeader()
          // 开始观看按钮
          this.StartWatching()
          // 主内容
          Scroll(this.scroller) {
            Column() {
              Column() {
                Stack({ alignContent: Alignment.TopStart }) {
                  // 背景虚化图
                  Column() {
                    //  images.large
                    Image(typeof this.animationInfo.images.large === 'string' ? this.animationInfo.images.large : "")
                      .width('100%')
                      .height('100%')
                      .objectFit(ImageFit.Cover)
                      .opacity(this.opacitySum)
                      .blur(50)
                      .borderRadius("2%")
                  }
                  .height(this.TOP_IMAGE_HEIGHT)

                  // 详细信息
                  Column() {
                    Column() {
                      Column() {
                        Text(this.animationInfo.name_cn)
                          .width('100%')
                          .height(60)
                          .letterSpacing(2)
                          .align(Alignment.End)
                          .font({ size: 25 })
                      }.justifyContent(FlexAlign.End)

                      Row() {
                        // images.large
                        Image(this.animationInfo.images.large)
                          .width(160)
                          .height(230)
                          .borderRadius(15)
                          .objectFit(ImageFit.Cover)
                        // 右侧信息区域
                        Column() {
                          Text("放送开始:")
                            .fontSize(15)
                            .fontColor(Color.Black)

                          // date
                          Text(this.animationInfo.date)
                            .fontSize(20)
                            .fontColor("#42733C")
                            .fontWeight(FontWeight.Bold)
                            .margin({ top: 6 })

                          // rating.total
                          Text(`${this.animationInfo.rating.total}人评分:`)
                            .fontSize(15)
                            .fontColor(Color.Black)
                            .margin({ top: 12 })

                          // rating.score
                          Row() {
                            Text(this.animationInfo.rating.score.toString())
                              .fontSize(20)
                              .fontColor("#42733C")
                              .fontWeight(FontWeight.Bold)

                            // rating.score
                            Rating({ rating: this.animationInfo.rating.score / 2, indicator: true })
                              .stepSize(0.1) // 步长
                              .height(25)
                              .width(140)
                              .margin({ left: 15 })
                          }
                          .margin({ top: 6 })

                          Text("Bangumi Ranked:")
                            .fontSize(15)
                            .fontColor(Color.Black)
                            .margin({ top: 12 })

                          // rating.rank
                          Text(`#${this.animationInfo.rating.rank}`)
                            .fontSize(20)
                            .fontColor("#42733C")
                            .fontWeight(FontWeight.Bold)
                            .margin({ top: 6 })
                          Blank()
                            .layoutWeight(1)
                          Row({ space: 10 }) {
                            Image($r('app.media.heart'))
                              .width(20)
                              .height(20)
                            Text("未追")
                              .fontColor(Color.White)
                          }
                          .alignItems(VerticalAlign.Center)
                          .justifyContent(FlexAlign.Center)
                          .width(126)
                          .height(45)
                          .backgroundColor("#296A34")
                          .borderRadius(40)
                        }
                        .layoutWeight(1)
                        .margin({ left: 15 })
                        .width(150)
                        .height(230)
                        .alignItems(HorizontalAlign.Start)
                      }
                      .width('100%')
                      .borderRadius(8)
                      .margin({ bottom: 20, top: 10 })
                    }.margin({ top: 97 }).padding({ left: 10 })
                  }.backdropBlur(100).height('140%').width("100%")
                }
                .height('47%').width("100%")
                .margin({ bottom: 20 })
                .opacity(this.opacitySum ? this.opacitySum : 1)
              }

              Column() {
                // Header
                this.Header('', "#F6FAF0")
                Column() {
                  if (this.currentIndex === 0) {
                    this.OverView()
                  } else if (this.currentIndex === 1) {
                    this.TuCao()
                  } else if (this.currentIndex === 2) {
                    this.Role()
                  } else if (this.currentIndex === 3) {
                    this.Comment()
                  } else if (this.currentIndex === 4) {
                    this.Marker()
                  }
                }
                .width('100%')
                .margin({ top: 15 })
              }
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Vertical)
          .onScrollEdge(async () => {
            if (this.currentIndex === 1) {
              this.offsetComment += 20
              // 发送请求获取更多数据
              await getAnimationComments(this.animationItemParm?.id, this.offsetComment, this.limitComment)
                .then(res => {
                  this.moreComments = res.data as Array<Comment>
                })
            }
          })
          .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState, scrollSource: ScrollSource) => {
            this.yOffsetSum += yOffset

            let newOpacity = 1 - (this.yOffsetSum / this.SCROLL_THRESHOLD)
            this.opacitySum = Math.max(0.1, Math.min(1.0, newOpacity));

            this.isSticky = this.yOffsetSum >= 295;

            return { xOffset, yOffset }
          })

          // 吸顶 Header
          if (this.isSticky) {
            this.HeaderComponent(155, "#EBEFE5", true)
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor("#F7FBF1")
    .onReady(async (content) => {
      this.pathStack = content.pathStack;
      this.animationItemParm = content.pathInfo.param as AnimationItem;
      await getAnimationItemInfo(this.animationItemParm.id).then(res => {
        this.animationInfo = res;
        if (this.animationInfo.images.large == "") {
          this.animationInfo.images.large = $r('app.media.defaultImage')
        }
      });
      this.isLoading = false;
    })
  }
}
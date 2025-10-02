import { AvatarUtil } from "../../common/AvatarUtil"
import { Loading } from "../../common/Loading"
import { AnimationItem } from "../../recommendpages/DefaultContent"
import { getAnimationComments } from "../../utils/HttpUtil"
import { LengthMetrics } from "@kit.ArkUI"
import { formatTime } from "../../utils/TimeUtil"

export interface AnimationCommentsResponse {
  data: Array<Comment>
}

export interface Comment {
  comment: string,
  id: number,
  rate: number,
  type: number,
  updatedAt: number,
  user: User
}

interface User {
  avatar: Avatar,
  group: number,
  id: number,
  joinedAt: number,
  nickname: string,
  sign: string,
  username: string
}

interface Avatar {
  large: string,
  medium: string,
  small: string
}

@Component
export struct TuCao {
  @State animationItemParm: AnimationItem = {} as AnimationItem
  @State animationCommentsInfo: AnimationCommentsResponse = {} as AnimationCommentsResponse;
  @State isLoading: boolean = true
  @State CommentCacheList: Array<Comment> = [];
  @State offsetComment: number = 0;
  @State limitComment: number = 20;
  @Prop @Watch('onCommentsChanged') moreComments: Array<Comment> = [];

  onCommentsChanged() {
    console.info(`TuCao: 评论列表更新了，当前条数: ${this.moreComments.length}`)
    this.moreComments.forEach(item => {
      this.CommentCacheList.push(item)
    })
  }

  async aboutToAppear(): Promise<void> {
    // 每一次请求
    await getAnimationComments(this.animationItemParm?.id, this.offsetComment, this.limitComment).then(res => {
      this.CommentCacheList = res.data as Array<Comment>
    })
    this.isLoading = false
  }

  build() {
    if (this.isLoading) {
      Loading()
    } else {
      Scroll() {
        Column() {
          ForEach(this.CommentCacheList, (animationComment: Comment, index: number) => {
            Column() {
              // 上半部分
              Row() {
                Row() {
                  AvatarUtil({ src: animationComment.user.avatar.small, avatarSize: 40 })
                  Column({ space: 2 }) { // 633
                    Text(animationComment.user.nickname)
                    Text(`${formatTime((Math.floor(new Date().getTime() / 1000) - animationComment.updatedAt))}前`)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 10 })
                }

                Rating({ rating: animationComment.rate / 2, indicator: true })
                  .width(90).height(20)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .justifyContent(FlexAlign.SpaceBetween)

              // 评论内容
              Row() {
                Text(`${animationComment.comment}`).lineSpacing(LengthMetrics.vp(2))
              }.width('100%').margin(15)

              // 分割线
              Divider().borderWidth(1).borderColor("#E8EBE2")
            }.margin({ top: 10 })
          })
        }
        .margin({
          left: 10,
          top: 20,
          right: 20,
          bottom: 20
        })
      }
      .scrollable(ScrollDirection.None)
      .scrollBar(BarState.Off)
    }
  }
}
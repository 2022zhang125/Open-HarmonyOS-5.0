import { AvatarUtil } from "../../common/AvatarUtil"
import { Loading } from "../../common/Loading"
import { AnimationItem } from "../../recommendpages/DefaultContent"
import { getAnimationMarkers } from "../../utils/HttpUtil"

export interface AnimationMarkerResponse {
  data: Array<MarkerInterface>,
  total: number
}

interface MarkerInterface {
  positions: Array<PositionInterface>,
  staff: Staff
}

interface PositionInterface {
  summary: string,
  type: Type
}

interface Type {
  cn: string,
  en: string,
  id: number,
  jp: string
}

interface Staff {
  comment: string,
  id: number,
  images: StaffImage,
  info: string,
  lock: boolean,
  name: string,
  nameCN: string,
  nsfw: boolean,
  type: number
}

interface StaffImage {
  grid: string,
  large: string,
  medium: string,
  small: string
}

@Component
export struct Marker {
  @State animationItemParm: AnimationItem = {} as AnimationItem
  @State isLoading: boolean = true
  @State markersInfo: Array<MarkerInterface> = [];

  aboutToAppear(): void {
    getAnimationMarkers(this.animationItemParm.id).then(res => {
      this.markersInfo = res.data
    })
    this.isLoading = false
  }

  build() {
    if (this.isLoading) {
      Loading()
    } else {
      Column() {
        ForEach(this.markersInfo, (marker: MarkerInterface, index: number) => {
          Row() {
            // 头像
            AvatarUtil({
              src : marker.staff.images ? marker.staff.images.grid : "https://bangumi.tv/img/info_only.png"
            , avatarSize: 40
            }).margin({ left: 20 })
            // 个人信息
            Row() {
              Column({ space: 5 }) {
                Text(marker.staff.name).fontWeight(FontWeight.Bold)
                Text(marker.staff.nameCN).fontSize(15)
              }.margin(20)
              .alignItems(HorizontalAlign.Start)

              // 角色
              Text(marker.positions[0].type.cn).margin({ right: 20 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .margin({ bottom: 10 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        })
      }
    }
  }
}
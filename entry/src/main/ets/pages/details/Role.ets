import { AvatarUtil } from "../../common/AvatarUtil"
import { Loading } from "../../common/Loading"
import { AnimationItem, AnimationResponse } from "../../recommendpages/DefaultContent"
import { getAnimationCharacters } from "../../utils/HttpUtil"

export interface Character extends AnimationResponse {
  actors: Array<Actor>,
  id: number,
  images: CharacterImage,
  name: string,
  relation: string,
  type: number
}

interface Actor {
  career: Array<string>,
  id: number,
  images: CharacterImage,
  locked: boolean,
  name: string,
  short_summary: string,
  type: number
}

interface CharacterImage {
  grid: string,
  large: string,
  medium: string,
  small: string
}

@Component
export struct Role {
  @State animationItemParm: AnimationItem = {} as AnimationItem
  @State animationCharacters: Array<Character> = []
  @State isLoading: boolean = true;

  @Builder
  CharacterDrawerLayout() {

  }

  aboutToAppear(): void {
    getAnimationCharacters(this.animationItemParm.id).then(res => {
      this.animationCharacters = res
    })
    this.isLoading = false
  }

  build() {
    if(this.isLoading){
      Loading()
    }else{
      Column() {
        ForEach(this.animationCharacters, (character: Character, index: number) => {
          Row() {
            // 头像
            AvatarUtil({
              src: character.images.grid
            , avatarSize: 40
            }).margin({ left: 20 })
            // 个人信息
            Row() {
              Column({ space: 5 }) {
                Text(character.name).fontWeight(FontWeight.Bold)
                Text(character.actors[0]?.name).fontSize(15)
              }.margin(20)
              .alignItems(HorizontalAlign.Start)

              // 角色
              Text(character.relation).margin({ right: 20 })
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

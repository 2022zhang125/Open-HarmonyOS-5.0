@Component
export struct AvatarUtil {
  // 头像图片源 (可以是本地资源或网络URL)
  @Prop src: Resource | string;
  // 头像尺寸 (统一宽高)
  @Prop avatarSize: number;

  build() {
    Image(this.src)
      .width(this.avatarSize)
      .height(this.avatarSize)
      // 关键：将 Image 裁剪为圆形
      .borderRadius('50%')
      // 确保图片填充整个圆形区域
      .objectFit(ImageFit.Cover)
  }
}
import { Loading } from './Loading';
import { webview } from '@kit.ArkWeb';

@Component
export struct WebComponent {
  private webController: WebviewController = new webview.WebviewController();
  @Prop url: string;
  @StorageLink('topHeight') topHeight: number = 0;
  @State isLoading: boolean = true;

  build() {
    Column() {
      Web({ src: this.url, controller: this.webController })
        .javaScriptAccess(true)
        .onPageBegin(() => {
          this.isLoading = true;
        })
        .onPageEnd(() => {
          this.isLoading = false;
        })
        .onErrorReceive((event) => {
          console.error("网页加载出错:", event);
          this.isLoading = false;
        })

      if (this.isLoading) {
        Loading()
          .position({ x: 0, y: 0 })
          .width('100%')
          .height('100%')
          .zIndex(1000)
      }
    }
    .width('100%')
    .height('100%')
  }
}
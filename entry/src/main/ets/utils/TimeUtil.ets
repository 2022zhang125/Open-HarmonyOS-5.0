/**
 * 格式化时间戳，转变为 x时、x分、x秒
 * @param time 时间戳(s)
 * @returns 时分秒
 */
export function formatTime(time: number): string {
  let result: string = "0";
  // 0 - 60 秒
  if (time >= 0 && time < 60) {
    result = Math.floor(time) + "秒"
    // 60(1分钟) - 3600(60分钟)
  } else if (time >= 60 && time < 3600) {
    result = Math.floor((time / 60)) + "分钟"
    // 3600(1小时) - 24 * 3600(1天)
  } else if (time >= 3600 && time < 24 * 3600) {
    result = Math.floor((time / 60 / 60)) + "小时"
  } else {
    // 24 * 3600(1天)
    result = Math.floor((time / (24 * 3600))) + "天"
  }
  return result;
}
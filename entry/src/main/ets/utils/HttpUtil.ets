import { http } from "@kit.NetworkKit";
import { Const } from "../common/Const";
import { AnimationResponse, AnimeRecommendResponse } from "../recommendpages/DefaultContent"; // 需要导入 AnimeResponse 类型
import { JSON } from "@kit.ArkTS";
import { AnimationDetailResponse } from "../pages/AnimationDetail";
import { AnimationCommentsResponse } from "../pages/details/TuCao";
import { Character } from "../pages/details/Role";
import { AnimationMarkerResponse } from "../pages/details/Marker";

function getRequest(url: string): Promise<http.HttpResponse> {
  const httpRequest = http.createHttp();
  return httpRequest.request(url, {
    method: http.RequestMethod.GET,
    readTimeout: 5000,
    header: {
      'Content-Type': 'application/json'
    },
    connectTimeout: 3000,
    extraData: {}
  });
}

function ParseResponseData<T extends AnimationResponse>(httpResult: http.HttpResponse): T {
  let resultData: T;
  if (typeof httpResult.result === 'string') {
    resultData = JSON.parse(httpResult.result) as T;
  } else {
    resultData = httpResult.result as T;
  }
  return resultData
}

/**
 * 获取首页展示信息
 * @param type 类型
 * @param limit 界限
 * @param offset 开始的位置
 * @returns 结果集
 */
export async function HttpRequestGet(type: number, limit: number, offset: number): Promise<AnimeRecommendResponse> {
  const url = Const.RECOMMEND_SERVER_URL + `?type=${type}&limit=${limit}&offset=${offset}`
  try {
    const res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.error("请求失败:", JSON.stringify(error));
    throw new Error(error);
  }
}


/**
 * 通过ID获取动画基本信息
 * @param id 动画ID
 */
export async function getAnimationItemInfo(id: number): Promise<AnimationDetailResponse> {
  const url = Const.ANIMATION_DETAIL_SERVER_URL + id;
  try {
    let res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.info("请求失败:", JSON.stringify(error))
    throw new Error(error)
  }
}

/**
 * 获取当前ID的20条评论
 * @param id 动画ID
 * @param offset 开始的位置
 * @param limit 界限
 */
export async function getAnimationComments(id: number, offset: number,
  limit: number): Promise<AnimationCommentsResponse> {
  // https://next.bgm.tv/p1/subjects/524707/comments?offset=0&limit=20
  const url = Const.ANIMATION_COMMENT_SERVER_URL + id + `/comments?offset=${offset}&limit=${limit}`
  try {
    let res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.info("请求失败:", JSON.stringify(error))
    throw new Error(error)
  }
}


/**
 * 获取动漫角色们
 * @param id 动漫ID
 * @returns 角色信息
 */
export async function getAnimationCharacters(id: number): Promise<Array<Character>> {
  const url = Const.ANIMATION_DETAIL_SERVER_URL + id + "/characters"
  try {
    let res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.info("请求失败:", JSON.stringify(error))
    throw new Error(error)
  }
}

/**
 * 获取动漫制作信息
 * @param id 动漫ID
 * @returns AnimationMarkerResponse
 */
export async function getAnimationMarkers(id: number): Promise<AnimationMarkerResponse> {
  // https://next.bgm.tv/p1/subjects/524707/staffs/persons
  const url = Const.ANIMATION_COMMENT_SERVER_URL + id + "/staffs/persons"
  try {
    let res: http.HttpResponse = await getRequest(url)
    return ParseResponseData(res)
  } catch (error) {
    console.info("请求失败:", JSON.stringify(error))
    throw new Error(error)
  }
}
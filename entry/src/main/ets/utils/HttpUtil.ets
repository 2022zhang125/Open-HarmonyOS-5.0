import { http } from "@kit.NetworkKit";
import { Const } from "../common/Const";
import {
  AnimationItem, AnimationResponse, AnimeRecommendResponse
} from "../recommendpages/DefaultContent"; // 需要导入 AnimeResponse 类型
import { JSON } from "@kit.ArkTS";
import { AnimationDetailResponse } from "../pages/AnimationDetail";
import { AnimationCommentsResponse } from "../pages/details/TuCao";
import { Character } from "../pages/details/Role";
import { AnimationMarkerResponse } from "../pages/details/Marker";
import { Body, SearchDataResponse } from "../views/Search";

/**
 * GET请求
 * @param url 请求地址
 * @returns 返回Response
 */
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

/**
 * POST请求
 * @param url POST请求地址
 * @param requestData 请求体数据
 * @returns 通常HttpResponse对象
 */
function postRequest(url: string, requestData: object): Promise<http.HttpResponse> {
  const httpRequest = http.createHttp()
  return httpRequest.request(url, {
    method: http.RequestMethod.POST,
    readTimeout: 5000,
    header: {
      'Content-Type': 'application/json'
    },
    connectTimeout: 3000,
    // 转为JSON
    extraData: JSON.stringify(requestData)
  })
}

/**
 * POST请求体构建
 * @param keyword 关键词
 * @param sort 排序方式
 * @param tag 标签
 * @param rank 等级
 * @returns POST请求体对象
 */
export function BuildBody(keyword: string, sort: string, tag: Array<string>, rank: number) {
  const body: Body = {
    "keyword": `${keyword}`,
    // heat,rank
    "sort": `${sort}`,
    "filter": {
      "type": [
        2
      ],
      "tag": tag,
      "rank": [
        `>=${rank}`,
        "<=99999"
      ],
      "nsfw": false
    }
  }
  return body
}

/**
 * 生成 20 - 10000的随机数，用于每次点击tab时的数据展示
 * @returns 随机数
 */
export function getRank(): number {
  return Math.floor(Math.random() * (10000 - 20 + 1)) + 20;
}

/**
 * 将AnimeRecommendResponse对象转为AnimationItem对象
 *
 * @param response AnimeRecommendResponse对象
 * @returns AnimationItem[] 数组
 */
export function transformToAnimations(response: AnimeRecommendResponse): AnimationItem[] {
  const result: Array<AnimationItem> = []
  for (let index = 0; index < response.data.length; index++) {
    const element = response.data[index];
    result.push({
      id: element.subject.id,
      title: element.subject.nameCN,
      image: element.subject.images.large
    })
  }
  return result;
}

export function transformSearchDataResponseToAnimations(response: SearchDataResponse,
  animations: AnimationItem[]): AnimationItem[] {
  response.data.forEach(item => {
    const animation: AnimationItem = {
      id: item.id,
      title: item.name_cn ? item.name_cn : item.name,
      image: item.image
    }
    animations.push(animation)
  })
  return animations
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

/**
 * POST请求 获取动画信息，通过Search信息
 * @requestMethod POST
 * @param body 请求体
 * @param limit 界限
 * @param offset 开始下标
 * @returns SearchDataResponse数据
 */
export async function getAnimationItemBySearch(body: object, limit: number,
  offset: number): Promise<SearchDataResponse> {
  const url = Const.API_BGM_TV_SERVER_URL + `/search/subjects?limit=${limit}&offset=${offset}`
  try {
    let res: http.HttpResponse = await postRequest(url, body)
    return ParseResponseData(res)
  } catch (error) {
    console.info("请求失败:", JSON.stringify(error))
    throw new Error(error)
  }
}

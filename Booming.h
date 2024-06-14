//
//  RxNetworks.h
//
//  Copyright (c) 2021 Condy https://github.com/YangKJ
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// 该组件主要是基于 Moya 搭建响应式数据绑定网络API架构，提供多种网络插件使用；
// 该框架也支持 Codable 使用，请导入Codable模块即可 pod 'HollowCodable'

// 如果觉得好用，希望您能STAR支持，你的 ⭐️ 是我持续更新的动力!
// 传送门：https://github.com/YangKJ/RxNetworks <备注：快捷打开浏览器命令，command + 鼠标左键>


// This component mainly builds responsive data binding network API architecture based on RxSwift + Moya.

// Part of the data reference comes from the Internet,
// And it is easy to use when summarizing it, so let's add it slowly.
// If you find it easy to use, I hope you can support STAR. Your ⭐️ is my motivation for updating!
// Portal: https://github.com/YangKJ/RxNetworks <Note: Open the browser command quickly, command + left mouse button>

/// 备注提示：
///
/// 再分享一个项目基础架构，快速搭建项目。感兴趣的朋友亦可使用；
/// 基于 MVVM + RxSwift 搭建响应式数据绑定基础架构，列表自带响应式刷新和空数据展示，提供组件化模块；
/// https://github.com/yangKJ/Rickenbacker
///
/// 图像显示框架，支持静态图像和动态图像混合显示；
/// https://github.com/yangKJ/ImageX
///
/// 滤镜框架，支持多种数据源；
/// https://github.com/yangKJ/Harbeth
///
/// 序列化与反序列化库，采用属性包装器设计；
/// https://github.com/yangKJ/HollowCodable

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double BoomingVersionNumber;

FOUNDATION_EXPORT const unsigned char BoomingVersionString[];

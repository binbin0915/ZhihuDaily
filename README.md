# 仿知乎日报 Swift 3.0
[TOC]

##前言
学习 Swift 语言也有一段时间了，为了增加实战经验，选择了结构相对简单的知乎日报项目来练手。

##关于项目
- 开发环境：Xcode 8， 语言：Swift 3.0
- 参考API: [GitHub](https://github.com/izzyleung/ZhihuDailyPurify/wiki/%E7%9F%A5%E4%B9%8E%E6%97%A5%E6%8A%A5-API-%E5%88%86%E6%9E%90)
- 界面布局以 storyboard 和纯代码相互结合方式
- 项目使用了 Alamofire 和 AlamofireImage 框架

##效果预览

![Preview](http://upload-images.jianshu.io/upload_images/3199099-7311a025b5481ebd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##启动图片
![启动图片](http://upload-images.jianshu.io/upload_images/3199099-6b87397adb9bf4e1.gif?imageMogr2/auto-orient/strip)

在首页控制器显示之前，在 `window` 上添加 `UIImageView`，第一次启动加载默认图片并开启子线程下载最新启动图，每次下载完成新的启动图片后缓存以供下次启动使用，动画使用的 `UIView.animate` + `transform`

##首页布局
![首页布局](http://upload-images.jianshu.io/upload_images/3199099-ca4cef56f594e00e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 占据全屏幕的 TableView，TableView 的 cell 使用 `UIStackView` 自动约束内部子控件
- 展示图片轮播的 BannerView( `UIView`)，置于 `TableView` 顶部
- 顶部模拟的导航栏：TopView( `UIView`) ->用于实现内容滚动导航栏渐变效果，TopLabel( `UILabel`) ->导航栏文字， RefreshView( `UIView`) ->展示下拉刷新动画，为避免 `TopView` 的透明度变化影响其他控件，不做嵌套处理

##主页 TableView
TableView 没啥好说的，无非发送网络请求，解析 JSON 数据包装成模型，获得模型数组，设置 cell 展示数据，需要注意 `header` 的设置，官方返回的date是一串日期字符串，格式化后使用

##图片轮播 Banner
![图片轮播](http://upload-images.jianshu.io/upload_images/3199099-0d9b6e50094356fd.gif?imageMogr2/auto-orient/strip)

- 界面：使用 `UIScrollView` 或者 `UICollection`都可以实现，这里用的 `UICollection`，内部并排摆放图片，再加一个 `UIPageControl` 显示索引。

- 循环轮播的逻辑：从 api 获取的数据为5个(1,2,3,4,5)，将首尾数据进行复制处理排列(5,1,2,3,4,5,1)并布置到 collectionView 中，再让界面加载前的 `contentOffset.x` 等于屏幕宽度，`scrollViewDidScroll` 方法中控制滚动到头和尾数据时调整`contentOffset.x ` 到对应位置即可（pageControl 逻辑与之类似），代码如下：

```
// MARK: - collectionView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let screenWidth = UIScreen.main.bounds.size.width
        let currentOffsetX = collectionView.contentOffset.x
        switch currentOffsetX {
        case 0 :
            collectionView.contentOffset.x = 5 * screenWidth
            pageControl.currentPage = 4
        case 6 * screenWidth :
            collectionView.contentOffset.x = screenWidth
            pageControl.currentPage = 0
        default:
            pageControl.currentPage = Int ((currentOffsetX) / screenWidth) - 1
            break
        }
        
    }
```
- 定时轮播：添加定时器执行 ` contentOffset.x + screenWidth` 即可，需要注意手指开始拖拽和结束拖拽的关闭和重启定时器逻辑

##下拉效果
![下拉效果](http://upload-images.jianshu.io/upload_images/3199099-48a71c2b0b3b9fad.gif?imageMogr2/auto-orient/strip)

 - Banner 拉伸
实现的方法是：给 BannerView 接收下拉 `contentOffset.y` 的属性，添加属性监听器 `DidSet`，随属性的变化改变 `bannerContentView.frame`（y ，height）， 注意 `clipsToBounds` 属性的设置

 - 下拉刷新动画
下拉刷新动画由 `CAShapeLayer` 绘制的白灰圆环和 `UIActivityIndicatorView` 菊花动画组成，再通过下拉的 `contentOffset.y` 进行控制圆环的绘制和菊花动画即可

## 导航栏跳转动画
![导航栏跳转动画](http://upload-images.jianshu.io/upload_images/3199099-b359995efe1fa6ff.gif?imageMogr2/auto-orient/strip)

因为自带导航栏在导航栏有变化的两个控制器切换时效果非常别扭（互相影响），所以决定隐藏系统导航栏自己模拟一个导航栏，导航控制器仅保留的跳转控制器和滑动返回功能


##导航栏透明度变化和标题文字变化
![导航栏效果.gif](http://upload-images.jianshu.io/upload_images/3199099-c0430da29b81b3f4.gif?imageMogr2/auto-orient/strip)

- 透明度变化：根据 `contentOffset.y` 设置一定比例调整 TopView 的 `alpha` 属性即可

- 标题文字变化：这个可以利用 `tableView` 的 `section header` 悬停顶部这个特点实现，根据当前展示的数据计算到达悬停的偏移量，在 `header` 悬停的时候隐藏 TopView 和更改 TitleLabel 文字。还有另外一种方法：在 `tableViewwillDisplay` 方法里用 `reduce`函数获取当前显示所有 cell 所属的 `section`，当上一个 `section` 完全消失时改变标题文字：

```
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

let displaySection = tableView.indexPathsForVisibleRows?.reduce(Int.max, {
            (partialResult, indexPath) -> Int in
            return min(partialResult, indexPath.section)
        })
        
        if displaySection == 0 {
            DispatchQueue.main.async { [weak self] in
                self!.topLabel.text = "今日热文"
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self!.topLabel.text = self!.models[displaySection!].formatDate
            }
        }
}
      
```

##自动加载下页数据
![自动加载下页数据.gif](http://upload-images.jianshu.io/upload_images/3199099-eeaf3c4e6e085bc8.gif?imageMogr2/auto-orient/strip)

在 ` tableViewwillDisplay` 方法中，提前在上一页数据还没有展示的时候发送网络请求，将数据模型加入模型数组中，局部刷新表格

```
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //提前加载下一列数据
        if indexPath.section == news.count - 1 && indexPath.row == 0 {
            loadPreviousData()
        }
}        
```

##控制器跳转
BannerView 和 cell 的点击都要将对应模型数据传递至详情页面控制器，BannerView 通过代理，cell 通过 `tableViewdidSelectRowAt`

##详情页面
- 布局： 一个全屏幕的 `UIWebView` 和 一个 `UIImageView`
- 数据处理： 这个页面展示的就是一个 `webView`，发送网络请求后拿到 `body` 和 `css` 数据，拼接 `html` 信息后用 `loadHTMLString` 方法加载即可
- 下拉图片拉伸效果：直接复用首页封装的 `bannerContentView`

##最后
水平有限，各位大神海涵，有改进之处望赐教，谢谢大家。
源码已传至 GitHub [仿知乎日报](https://github.com/dmcldming/ZhihuDaily)。





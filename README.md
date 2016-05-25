# YPTabBarController
自定义的TabBarController

##安装方法：
pod 'YPTabBarController'<br>
或者，<br>
直接导入YPTabBarController文件夹下的文件。

##功能介绍：

1. 替代系统的UITabBarController，以下属性均可修改：<br>
    a) TabBar：位置、大小等；<br>
    b) TabItem：图像、选中背景、title字体、title颜色；<br>
    c) Badge，支持数字badge和小圆点badge，可自定义：位置和大小、背景颜色、背景图像、badge title字体、badge title颜色；<br>
2. 替代系统的UISegmentControl<br>
3. 仿网易、搜狐等新闻客户端的可滑动的内容视图和TabBar，支持滑动内容视图时，对应TabItem的字体、颜色、选中背景跟随内容视图的滚动进行平滑切换。

##效果展示：
         
1. 固定宽度的TabItem：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/FixedItemWidthTab.gif) 
2. 根据TabItem的字体确认宽度的TabItem：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/DynamicItemWidthTab.gif)
3. 内容视图不可滚动，TabItem选中背景支持切换动画：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/UnscrollTab.gif) 
4. 系统Segment：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/Segment.gif) 

##使用方法
使用方法参见Demo


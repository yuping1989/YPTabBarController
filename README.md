# YPTabBarController
一款功能十分强大TabBarController，几乎你所能想到的关于TabBar的需求，它都能实现。

##安装方法：
pod 'YPTabBarController'<br>
或者，<br>
直接将YPTabBarController文件夹拖入工程。

##功能介绍：
功能强大的自定义TabBarController，可以自定义：<br>
1. 替代系统的UITabBarController，以下属性均可自定义：<br>
    a) TabBar：位置、大小、边框、圆角、分割线、内容支持滚动等；<br>
    b) TabItem：图像、选中背景、title字体、title颜色等，均包含选中和未选中两种状态；<br>
    c) Badge：支持数字badge和小圆点badge，可自定义：位置、大小、背景颜色、背景图像、badge title字体、badge title颜色等；<br>
2. 替代系统的UISegmentControl，且功能更加强大；<br>
3. 仿网易、搜狐等新闻客户端的可滑动的内容视图和TabBar，支持滑动内容视图时，对应TabItem的字体、颜色、选中背景跟随内容视图的滚动进行平滑渐变切换；<br>
4. 多个代理方法，可以自由适应各种需求；<br>
5. 可以添加一个居中的特殊的YPTabItem按钮，类似于新浪微博中间的“+”号按钮；

##2.2版本功能更新：
1. YPTabBarController增加interceptRightSlideGuetureInFirstPage和interceptLeftSlideGuetureInLastPage属性，设置为YES可拦截content scrollView的滑动手势，避免左右侧边栏和右拖返回的手势冲突；<br>
2. YPTabBar代理方法完善，支持should、will、did等3个代理方法；<br>
3. 修复跳转到其他界面，所有child view controller都调用viewWillAppear等方法的问题；

##效果展示：
         
1. 根据TabItem的字体确认宽度的TabItem：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/DynamicItemWidthTab.gif)
<br><br>
2. 固定宽度的TabItem：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/FixedItemWidthTab.gif) 
<br><br>
3. 内容视图不可滚动，TabItem选中背景支持切换动画：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/UnscrollTab.gif) 
<br><br>
4. 系统Segment：<br>
![](https://github.com/yuping1989/YPTabBarController/blob/master/YPTabBarController/Demo/SegmentTab.gif) 

##使用方法
使用方法参见Demo

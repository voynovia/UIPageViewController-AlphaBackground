//
//  PageViewController.swift
//  UIPageViewController+AlphaBackground
//
//  Created by Igor Voynov on 30.03.17.
//  Copyright © 2017 Igor Voynov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PageViewController: UIPageViewController {
    
    weak var parentVC: ViewController!
    
    fileprivate let disposeBag = DisposeBag()
    
    var array = Variable<[UIViewController]>([])
    
    let pendingPageIndex = Variable<Int>(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstVC = array.value.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        pendingPageIndex.asDriver().drive(parentVC.pendingPageIndex).addDisposableTo(disposeBag)
        
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
                scrollView.frame = UIScreen.main.bounds
            }
            if let pageControl = view as? UIPageControl {
                pageControl.backgroundColor = .clear
            }
        }
    }
        
}

extension PageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.rx.contentOffset.asDriver().map({$0.x}).drive(parentVC.xOffset).addDisposableTo(disposeBag)
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first, let index = array.value.index(of: vc) {
            pendingPageIndex.value = index
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = array.value.index(of: viewController) else { return nil }
        index -= 1
        guard index >= 0 else { return array.value.last }
        return array.value[index]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = array.value.index(of: viewController) else { return nil }
        index += 1
        guard index < array.value.count else { return array.value.first }
        return array.value[index]
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return array.value.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vc = viewControllers?.first, let index = array.value.index(of: vc) else { return 0 }
        return index
    }
}

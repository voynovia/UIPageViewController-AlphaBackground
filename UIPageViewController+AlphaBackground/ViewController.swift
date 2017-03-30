//
//  ViewController.swift
//  UIPageViewController+AlphaBackground
//
//  Created by Igor Voynov on 30.03.17.
//  Copyright © 2017 Igor Voynov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    fileprivate let disposeBag = DisposeBag()
    
    let pages = Variable<[Page]>([])
    
    let pendingPageIndex = Variable<Int>(0)
    
    var xOffset = Variable<CGFloat>(0)
    var alphaView = Variable<CGFloat>(1)
    
    var frontView = UIView(frame: UIScreen.main.bounds)
    var backView = UIView(frame: UIScreen.main.bounds)
    
    var width: CGFloat { return UIScreen.main.bounds.width }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.insertSubview(frontView, at: 0)
        self.view.insertSubview(backView, at: 0)
        
        guard let pageVC = self.childViewControllers.last as? PageViewController else { return }
        pageVC.parentVC = self
        
        pages.value.append(contentsOf: [Page(text: "ONE", backgroundColor: .red),
                                        Page(text: "TWO", backgroundColor: .blue)])
        frontView.backgroundColor = pages.value.first?.backgroundColor
        
        pages.asDriver().map { $0.map { self.setPage($0) } }.drive(pageVC.array).addDisposableTo(disposeBag)
        
        alphaView.asDriver().drive(frontView.rx.alpha).addDisposableTo(disposeBag)
        
        xOffset.asDriver().distinctUntilChanged().drive(onNext: { xOffset in
            self.backView.backgroundColor = self.pages.value[self.pendingPageIndex.value].backgroundColor
            let offset = xOffset < self.width ? self.width - xOffset : xOffset - self.width
            self.alphaView.value = abs(offset / self.width - 1)
            if xOffset == 0 || xOffset == self.width * 2 {
                self.frontView.backgroundColor = self.backView.backgroundColor
            }
        }).addDisposableTo(disposeBag)
        
    }
    
    func setPage(_ page: Page) -> UIViewController {
        let vc = UIViewController()
        let label = UILabel()
        label.text = page.text
        label.font = UIFont.systemFont(ofSize: 120)
        vc.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        return vc
    }

}

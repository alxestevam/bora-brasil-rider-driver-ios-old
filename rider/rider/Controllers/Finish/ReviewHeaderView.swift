//
//  ReviewHeaderView.swift
//  rider
//
//  Created by Victor Baleeiro on 19/09/20.
//  Copyright © 2020 minimal. All rights reserved.
//

import UIKit

final class ReviewHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // Override `textLabel` to add `@IBOutlet` annotation
    @IBOutlet override var textLabel: UILabel? {
        get { return _textLabel }
        set { _textLabel = newValue }
    }
    private var _textLabel: UILabel?

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewContent: UIView!
}
